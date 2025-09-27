# app/services/kubernetes_client.rb
class KubernetesClient
  require 'kubeclient'
  require 'json'
  
  def initialize(namespace)
    @namespace = namespace || 'default'
    configure_client if Rails.env.production?
  end
  
  # Création d'un job d'entraînement
  def create_training_job(job_id, workspace_dir)
    return simulate_job if Rails.env.development?
    
    job_spec = build_job_spec(
      name: "training-job-#{job_id}",
      workspace_dir: workspace_dir,
      command: "python /app/train.py --config #{workspace_dir}/job_config.json"
    )
    
    create_job(job_spec)
  end
  
  # Déploiement d'un modèle
  def deploy_model(job_id, workspace_dir)
    return simulate_job if Rails.env.development?
    
    # Création du déploiement
    deployment_spec = build_deployment_spec(
      name: "model-#{job_id}",
      workspace_dir: workspace_dir
    )
    
    # Création du service associé
    service_spec = build_service_spec(
      name: "model-#{job_id}"
    )
    
    # Déploiement
    begin
      @client.create_deployment(deployment_spec)
      @client.create_service(service_spec)
      
      true
    rescue => e
      Rails.logger.error("Erreur lors du déploiement: #{e.message}")
      false
    end
  end
  
  # Récupération du statut d'un job
  def get_job_status(job_name)
    return { status: 'simulated' } if Rails.env.development?
    
    begin
      job = @client.get_job(job_name, @namespace)
      
      if job.status.succeeded.to_i > 0
        { status: 'completed' }
      elsif job.status.failed.to_i > 0
        { status: 'failed' }
      else
        { status: 'running' }
      end
    rescue => e
      Rails.logger.error("Erreur lors de la récupération du statut: #{e.message}")
      { status: 'unknown', error: e.message }
    end
  end
  
  # Suppression d'un job
  def delete_job(job_name)
    return true if Rails.env.development?
    
    begin
      @client.delete_job(job_name, @namespace)
      true
    rescue => e
      Rails.logger.error("Erreur lors de la suppression du job: #{e.message}")
      false
    end
  end
  
  # Suppression d'un déploiement et de son service
  def delete_deployment(deployment_name)
    return true if Rails.env.development?
    
    begin
      @client.delete_deployment(deployment_name, @namespace)
      @client.delete_service(deployment_name, @namespace)
      true
    rescue => e
      Rails.logger.error("Erreur lors de la suppression du déploiement: #{e.message}")
      false
    end
  end
  
  private
  
  # Configuration du client Kubernetes
  def configure_client
    config = if File.exist?('~/.kube/config')
      # Config locale pour le développement sur Kubernetes
      Kubeclient::Config.read(File.expand_path('~/.kube/config'))
    else
      # Config pour les déploiements sur un cluster
      Kubeclient::Config.read_cluster_config
    end
    
    context = config.context
    
    @client = Kubeclient::Client.new(
      context.api_endpoint,
      'v1',
      ssl_options: context.ssl_options,
      auth_options: context.auth_options
    )
    
    # Vérifier la connexion
    begin
      @client.discover
    rescue => e
      Rails.logger.error("Erreur de connexion à Kubernetes: #{e.message}")
    end
  end
  
  # Construction d'une spécification de job
  def build_job_spec(name:, workspace_dir:, command:)
    {
      metadata: {
        name: name,
        namespace: @namespace
      },
      spec: {
        template: {
          metadata: {
            labels: {
              job: name
            }
          },
          spec: {
            containers: [
              {
                name: "job-container",
                image: "souverainia/ai-training:latest",
                command: ["/bin/sh", "-c", command],
                resources: {
                  limits: {
                    memory: "8Gi",
                    cpu: "4",
                    "nvidia.com/gpu": 1
                  }
                },
                volumeMounts: [
                  {
                    mountPath: "/data",
                    name: "data-volume"
                  }
                ]
              }
            ],
            volumes: [
              {
                name: "data-volume",
                hostPath: {
                  path: workspace_dir
                }
              }
            ],
            restartPolicy: "Never"
          }
        },
        backoffLimit: 4
      }
    }
  end
  
  # Construction d'une spécification de déploiement
  def build_deployment_spec(name:, workspace_dir:)
    {
      metadata: {
        name: name,
        namespace: @namespace,
        labels: {
          app: name
        }
      },
      spec: {
        replicas: 1,
        selector: {
          matchLabels: {
            app: name
          }
        },
        template: {
          metadata: {
            labels: {
              app: name
            }
          },
          spec: {
            containers: [
              {
                name: "model-container",
                image: "souverainia/ai-inference:latest",
                ports: [
                  {
                    containerPort: 8080
                  }
                ],
                env: [
                  {
                    name: "MODEL_PATH",
                    value: "#{workspace_dir}/model"
                  }
                ],
                volumeMounts: [
                  {
                    mountPath: "/models",
                    name: "model-volume"
                  }
                ],
                resources: {
                  limits: {
                    memory: "4Gi",
                    cpu: "2"
                  }
                }
              }
            ],
            volumes: [
              {
                name: "model-volume",
                hostPath: {
                  path: workspace_dir
                }
              }
            ]
          }
        }
      }
    }
  end
  
  # Construction d'une spécification de service
  def build_service_spec(name:)
    {
      metadata: {
        name: name,
        namespace: @namespace
      },
      spec: {
        selector: {
          app: name
        },
        ports: [
          {
            port: 80,
            targetPort: 8080
          }
        ],
        type: "ClusterIP"
      }
    }
  end
  
  # Création d'un job
  def create_job(job_spec)
    begin
      @client.create_job(job_spec)
      true
    rescue => e
      Rails.logger.error("Erreur lors de la création du job: #{e.message}")
      false
    end
  end
  
  # Simulation d'un job pour le développement
  def simulate_job
    true
  end
end