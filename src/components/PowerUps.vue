<template>
  <v-card class="power-ups-container mb-4 mx-auto" flat max-width="500px">
    <v-card-title class="text-center pb-2 text-h6">
      <v-icon icon="mdi-lightning-bolt" color="amber" class="mr-1"></v-icon>
      Power-Ups
    </v-card-title>
    
    <v-card-text class="pa-2">
      <div class="d-flex justify-space-between">
        <!-- Time Freeze Power-up -->
        <v-btn
          variant="outlined"
          color="blue"
          :disabled="!canAfford('timeFreeze') && game.powerUpInventory.timeFreeze === 0"
          @click="handlePowerUp('timeFreeze')"
          class="power-up-btn"
        >
          <v-icon icon="mdi-clock-outline" size="24" class="mb-1"></v-icon>
          <div class="d-flex flex-column align-center">
            <span class="power-up-name">TIME FREEZE</span>
            <div v-if="game.powerUpInventory.timeFreeze > 0" class="inventory-tag">
              {{ game.powerUpInventory.timeFreeze }}
            </div>
            <div v-else class="cost-tag">
              <v-icon icon="mdi-coin" color="amber" size="small"></v-icon>
              <small>5</small>
            </div>
          </div>
        </v-btn>

        <!-- Hint Power-up -->
        <v-btn
          variant="outlined"
          color="green"
          :disabled="!canAfford('hint') && game.powerUpInventory.hint === 0"
          @click="handlePowerUp('hint')"
          class="power-up-btn"
        >
          <v-icon icon="mdi-lightbulb-outline" size="24" class="mb-1"></v-icon>
          <div class="d-flex flex-column align-center">
            <span class="power-up-name">HINT</span>
            <div v-if="game.powerUpInventory.hint > 0" class="inventory-tag">
              {{ game.powerUpInventory.hint }}
            </div>
            <div v-else class="cost-tag">
              <v-icon icon="mdi-coin" color="amber" size="small"></v-icon>
              <small>3</small>
            </div>
          </div>
        </v-btn>

        <!-- Double Points Power-up -->
        <v-btn
          variant="outlined"
          color="purple"
          :disabled="!canAfford('doublePoints') && game.powerUpInventory.doublePoints === 0"
          @click="handlePowerUp('doublePoints')"
          class="power-up-btn"
        >
          <v-icon icon="mdi-star-outline" size="24" class="mb-1"></v-icon>
          <div class="d-flex flex-column align-center">
            <span class="power-up-name">DOUBLE POINTS</span>
            <div v-if="game.powerUpInventory.doublePoints > 0" class="inventory-tag">
              {{ game.powerUpInventory.doublePoints }}
            </div>
            <div v-else class="cost-tag">
              <v-icon icon="mdi-coin" color="amber" size="small"></v-icon>
              <small>8</small>
            </div>
          </div>
        </v-btn>
      </div>
    </v-card-text>
  </v-card>
</template>

<script setup>
import { ref } from 'vue';
import { useGameStore } from '../stores/gameStore';

const game = useGameStore();

// Event emitter
const emit = defineEmits(['useHint', 'useTimeFreeze']);

function canAfford(powerUp) {
  const costs = {
    timeFreeze: 5,
    hint: 3,
    doublePoints: 8
  };
  
  return game.coins >= costs[powerUp];
}

function handlePowerUp(powerUp) {
  // If player already has this power-up, use it
  if (game.powerUpInventory[powerUp] > 0) {
    const success = game.usePowerUp(powerUp);
    
    if (success) {
      // Emit events for certain power-ups that require parent component action
      if (powerUp === 'hint') {
        emit('useHint');
      } else if (powerUp === 'timeFreeze') {
        emit('useTimeFreeze'); 
      }
      // Double points doesn't need immediate action, it affects the next correct answer
    }
  } else {
    // Otherwise, try to buy it
    game.buyPowerUp(powerUp);
  }
}
</script>

<style scoped>
.power-ups-container {
  margin-bottom: 16px;
  background: rgba(255, 255, 255, 0.9);
  border-radius: 12px;
}

.power-up-btn {
  flex-direction: column;
  padding: 8px;
  border-radius: 12px;
  min-width: 100px;
  margin: 0 4px;
  transition: all 0.2s ease;
}

.power-up-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.power-up-name {
  font-size: 0.9rem;
  white-space: nowrap;
}

.inventory-tag {
  background-color: rgba(0, 0, 0, 0.1);
  border-radius: 4px;
  padding: 0px 4px;
  margin-top: 4px;
  font-size: 0.7rem;
}

.cost-tag {
  display: flex;
  align-items: center;
  margin-top: 4px;
  font-size: 0.7rem;
}
</style>