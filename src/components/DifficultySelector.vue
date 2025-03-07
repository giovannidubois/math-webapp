<template>
  <v-card class="difficulty-selector pa-2 mx-auto" flat max-width="500px">
    <v-btn-toggle
      v-model="selectedDifficulty"
      color="primary"
      class="difficulty-toggle"
      density="comfortable"
      rounded="lg"
    >
      <v-btn value="easy" prepend-icon="mdi-emoticon-happy-outline">
        EASY
      </v-btn>
      <v-btn value="medium" prepend-icon="mdi-emoticon-outline">
        MEDIUM
      </v-btn>
      <v-btn value="hard" prepend-icon="mdi-emoticon-cool-outline">
        HARD
      </v-btn>
    </v-btn-toggle>
  </v-card>
</template>

<script setup>
import { ref, computed, watch } from 'vue';
import { useGameStore } from '../stores/gameStore';

const game = useGameStore();

// Computed property for two-way binding with v-model
const selectedDifficulty = computed({
  get: () => game.difficulty,
  set: (value) => {
    game.setDifficulty(value);
    emit('difficultyChanged', value);
  }
});

const emit = defineEmits(['difficultyChanged']);
</script>

<style scoped>
.difficulty-selector {
  margin-bottom: 16px;
  background: rgba(255, 255, 255, 0.9);
  border-radius: 12px;
  display: flex;
  justify-content: center;
}

.difficulty-toggle {
  /* width: 100%; */
}
</style>