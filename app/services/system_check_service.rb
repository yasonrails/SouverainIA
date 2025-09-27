# app/services/system_check_service.rb
class SystemCheckService
  def initialize
    @config = load_config
  end

  # Vérification de l'espace de stockage disponible
  def check_storage(required_size_mb)
    if Rails.env.production?
      # En production, vérifier l'espace réel
      available_space = get_available_storage
      if available_space < required_size_mb
        return { success: false, message: "Espace insuffisant. Nécessaire: #{required_size_mb}MB, Disponible: #{available_space}MB" }
      end
    end
    
    { success: true, message: "Espace de stockage suffisant" }
  end

  # Vérification des ressources système disponibles
  def check_resources(requirements)
    if Rails.env.production?
      # Vérification des GPUs disponibles
      if requirements[:gpu_required] && !gpu_available?
        return { success: false, message: "Aucun GPU disponible" }
      end
      
      # Vérification de la mémoire disponible
      required_memory = requirements[:memory_mb] || 4000 # 4GB par défaut
      if get_available_memory < required_memory
        return { success: false, message: "Mémoire insuffisante" }
      end
    end
    
    { success: true, message: "Ressources suffisantes" }
  end

  # Obtention de l'état actuel du système
  def system_status
    if Rails.env.production?
      {
        storage: {
          total: get_total_storage,
          available: get_available_storage,
          used_percent: get_storage_usage_percent
        },
        memory: {
          total: get_total_memory,
          available: get_available_memory,
          used_percent: get_memory_usage_percent
        },
        cpu: {
          cores: get_cpu_cores,
          load: get_cpu_load
        },
        gpu: gpu_status
      }
    else
      # En développement, retourner des valeurs simulées
      {
        storage: { total: 1000000, available: 800000, used_percent: 20 },
        memory: { total: 32000, available: 24000, used_percent: 25 },
        cpu: { cores: 8, load: 0.2 },
        gpu: { available: 2, models: [ { name: 'NVIDIA A100', memory: '80GB' }, { name: 'NVIDIA A100', memory: '80GB' } ] }
      }
    end
  end
  
  private
  
  # Chargement de la configuration
  def load_config
    YAML.load_file(Rails.root.join('config', 'system_resources.yml'))[Rails.env]
  rescue
    { storage_path: '/data', min_free_space_mb: 5000 }
  end
  
  # Méthodes pour vérifier l'espace disque en production
  def get_available_storage
    stats = Sys::Filesystem.stat(@config['storage_path'])
    stats.block_size * stats.blocks_available / (1024 * 1024) # Convertir en MB
  rescue
    50000 # Valeur par défaut en cas d'erreur
  end
  
  def get_total_storage
    stats = Sys::Filesystem.stat(@config['storage_path'])
    stats.block_size * stats.blocks / (1024 * 1024) # Convertir en MB
  rescue
    100000 # Valeur par défaut en cas d'erreur
  end
  
  def get_storage_usage_percent
    stats = Sys::Filesystem.stat(@config['storage_path'])
    100 - ((stats.blocks_available.to_f / stats.blocks.to_f) * 100).round(2)
  rescue
    30 # Valeur par défaut en cas d'erreur
  end
  
  # Méthodes pour vérifier la mémoire en production
  def get_available_memory
    `free -m | grep Mem`.split[6].to_i
  rescue
    8000 # Valeur par défaut en cas d'erreur
  end
  
  def get_total_memory
    `free -m | grep Mem`.split[1].to_i
  rescue
    16000 # Valeur par défaut en cas d'erreur
  end
  
  def get_memory_usage_percent
    mem_info = `free -m | grep Mem`.split
    used = mem_info[2].to_i
    total = mem_info[1].to_i
    ((used.to_f / total.to_f) * 100).round(2)
  rescue
    50 # Valeur par défaut en cas d'erreur
  end
  
  # Méthodes pour vérifier le CPU en production
  def get_cpu_cores
    `nproc`.strip.to_i
  rescue
    4 # Valeur par défaut en cas d'erreur
  end
  
  def get_cpu_load
    `cat /proc/loadavg`.split(' ')[0].to_f
  rescue
    1.0 # Valeur par défaut en cas d'erreur
  end
  
  # Méthodes pour vérifier les GPUs en production
  def gpu_available?
    !`nvidia-smi -L 2>/dev/null`.empty?
  rescue
    false
  end
  
  def gpu_status
    output = `nvidia-smi --query-gpu=name,memory.total --format=csv,noheader 2>/dev/null`
    if output.empty?
      { available: 0, models: [] }
    else
      gpus = output.strip.split("\n").map do |line|
        name, memory = line.split(',').map(&:strip)
        { name: name, memory: memory }
      end
      
      { available: gpus.size, models: gpus }
    end
  rescue
    { available: 0, models: [] }
  end
end