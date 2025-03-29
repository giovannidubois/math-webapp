<template>
  <v-card class="progress-tracker" flat>
    <v-card-text class="tracker-content pa-2">
      <!-- Current Location -->
      <div class="location-info">
        <v-icon icon="mdi-map-marker" color="primary" class="mr-1"></v-icon>
        <span class="font-weight-bold">{{ currentCountry }}</span>
        <v-icon icon="mdi-arrow-right" size="small" class="mx-1"></v-icon>
        <span>{{ currentLandmark }}</span>
      </div>

      <!-- Progress Indicators -->
      <div class="indicators-container">
        <!-- Tickets -->
        <div class="d-flex align-center mr-4">
          <v-icon icon="mdi-ticket" color="amber-darken-2" class="mr-1"></v-icon>
          <div class="progress-circle-container">
            <div v-for="i in 5" :key="i" 
              :class="['progress-circle', { filled: tickets >= i }]">
            </div>
          </div>
        </div>

        <!-- Coins -->
        <div class="d-flex align-center">
          <v-icon icon="mdi-coin" color="amber" class="mr-1"></v-icon>
          <span class="font-weight-bold">{{ coins }}</span>
        </div>
      </div>
    </v-card-text>
  </v-card>
</template>

<script setup>
import { computed } from 'vue';
import { useGameStore } from '../stores/gameStore';

const game = useGameStore();

const tickets = computed(() => game.tickets);
const coins = computed(() => game.coins);
const currentCountry = computed(() => game.countries[game.currentCountryIndex].name);
const currentLandmark = computed(() => 
  game.countries[game.currentCountryIndex].landmarks[game.currentLandmarkIndex]
);
</script>

<style scoped>
.progress-tracker {
  width: 100%;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.9) !important;
  margin-bottom: 10px;
  height: auto !important;
  min-height: 35px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1) !important;
}

.tracker-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 100%;
  padding: 8px 16px !important;
}

.location-info {
  font-size: 0.9rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 60%;
  display: flex;
  align-items: center;
}

.indicators-container {
  display: flex;
  align-items: center;
  height: 100%;
}

.progress-circle-container {
  display: flex;
  gap: 4px;
  height: 12px;
}

.progress-circle {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  border: 2px solid #FFC107;
  background: transparent;
  flex-shrink: 0;
}

.progress-circle.filled {
  background: #FFC107;
}

/* Responsive adjustments for smaller screens */
@media (max-width: 400px) {
  .location-info {
    font-size: 0.8rem;
    max-width: 50%;
  }
  
  .progress-circle {
    width: 10px;
    height: 10px;
  }
  
  .tracker-content {
    padding: 6px 12px !important;
  }
}
</style>