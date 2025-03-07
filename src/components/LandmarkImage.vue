<template>
  <div 
    class="landmark-image"
    :class="{ 'is-loading': loading, 'has-error': error }"
    :style="imageStyle">
    <div v-if="loading" class="image-overlay loading-overlay">
      <v-progress-circular indeterminate color="primary"></v-progress-circular>
    </div>
    <div v-if="error" class="image-overlay error-overlay">
      <v-icon icon="mdi-image-off" size="large"></v-icon>
      <p>
        Image not available
        <span 
          v-if="canTryAlternate" 
          class="retry-link"
          @click="tryAlternateExtension"
        >
          Try alternate format
        </span>
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useGameStore } from '../stores/gameStore';

const game = useGameStore();
const canTryAlternate = ref(true);

const props = defineProps({
  src: {
    type: String,
    required: true
  },
  fallbackGradient: {
    type: String,
    default: 'linear-gradient(to bottom, #7DCEA0, #85C1E9)'
  }
});

const loading = ref(true);
const error = ref(false);
const imageLoaded = ref(false);

// Compute the background style
const imageStyle = computed(() => {
  if (error.value) {
    return { background: props.fallbackGradient };
  }
  
  return { 
    backgroundImage: imageLoaded.value 
      ? `linear-gradient(rgba(125, 206, 160, 0.3), rgba(133, 193, 233, 0.3)), url(${props.src})`
      : props.fallbackGradient,
    backgroundSize: 'cover',
    backgroundPosition: 'center',
    backgroundRepeat: 'no-repeat'
  };
});

// Try using the alternate extension
function tryAlternateExtension() {
  const newPath = game.tryAlternateExtension();
  loadImage(newPath);
  canTryAlternate.value = false; // Only allow one retry
}

// Load the image
function loadImage(src) {
  loading.value = true;
  error.value = false;
  imageLoaded.value = false;
  
  const img = new Image();
  
  img.onload = () => {
    loading.value = false;
    imageLoaded.value = true;
    console.log('Image loaded successfully:', src);
  };
  
  img.onerror = () => {
    loading.value = false;
    error.value = true;
    console.error(`Failed to load image: ${src}`);
  };
  
  img.src = src;
}

// Watch for src changes
watch(() => props.src, (newSrc) => {
  if (newSrc) {
    canTryAlternate.value = true; // Reset for new images
    loadImage(newSrc);
  }
});

// Load the image on mount
onMounted(() => {
  if (props.src) {
    loadImage(props.src);
  }
});
</script>

<style scoped>
.landmark-image {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  transition: background-image 0.5s ease;
  z-index: 0;
}

.image-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: rgba(0, 0, 0, 0.5);
  color: white;
  z-index: 1;
}

.loading-overlay {
  background: rgba(0, 0, 0, 0.3);
}

.error-overlay p {
  margin-top: 8px;
  font-size: 14px;
  text-align: center;
}

.retry-link {
  display: block;
  margin-top: 8px;
  color: #4CAF50;
  text-decoration: underline;
  cursor: pointer;
}

.retry-link:hover {
  color: #81C784;
}
</style>