<template>
  <div class="keyboard-container">
    <!-- Portrait mode keyboard (calculator style) -->
    <div class="keyboard-layout">
      <!-- First row: 1-2-3 -->
      <div class="keyboard-row">
        <v-btn
          v-for="num in [1, 2, 3]"
          :key="num"
          class="keyboard-btn number-btn"
          variant="elevated"
          color="primary"
          @click="press(num)"
        >
          {{ num }}
        </v-btn>
      </div>
      
      <!-- Second row: 4-5-6 -->
      <div class="keyboard-row">
        <v-btn
          v-for="num in [4, 5, 6]"
          :key="num"
          class="keyboard-btn number-btn"
          variant="elevated"
          color="primary"
          @click="press(num)"
        >
          {{ num }}
        </v-btn>
      </div>
      
      <!-- Third row: 7-8-9 -->
      <div class="keyboard-row">
        <v-btn
          v-for="num in [7, 8, 9]"
          :key="num"
          class="keyboard-btn number-btn"
          variant="elevated"
          color="primary"
          @click="press(num)"
        >
          {{ num }}
        </v-btn>
      </div>
      
      <!-- Fourth row: Negative, 0, Delete -->
      <div class="keyboard-row">
        <!-- Negative button -->
        <v-btn
          class="keyboard-btn function-btn"
          variant="elevated"
          color="secondary"
          @click="press('-')"
        >
          <span class="font-weight-bold">−</span>
        </v-btn>
        
        <!-- Zero button -->
        <v-btn
          class="keyboard-btn number-btn"
          variant="elevated"
          color="primary"
          @click="press(0)"
        >
          0
        </v-btn>
        
        <!-- Delete button -->
        <v-btn
          class="keyboard-btn delete-btn"
          variant="elevated"
          color="error"
          @click="backspace"
        >
          <div class="delete-content">DEL</div>
        </v-btn>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';

const emit = defineEmits(['input']);

function press(num) {
  emit('input', num.toString());
}

function backspace() {
  emit('input', 'delete');
}
</script>

<style scoped>
.keyboard-container {
  width: 100%;
  margin: 16px 0;
}

.keyboard-layout {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
}

.keyboard-row {
  display: flex;
  justify-content: center;
  gap: 10px;
  width: 100%;
  max-width: 300px;
}

.keyboard-btn {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  font-size: 1.5rem;
  font-weight: bold;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.1s, box-shadow 0.1s;
}

.keyboard-btn:active {
  transform: translateY(2px);
  box-shadow: 0 2px 2px rgba(0, 0, 0, 0.1);
}

.number-btn {
  background: #4A69BD;
  color: white;
}

.function-btn {
  background: #5758BB;
  color: white;
}

.delete-btn {
  background: #E15F41;
  color: white;
}

.delete-content {
  font-size: 1.2rem;
  font-weight: bold;
}

/* Media queries for responsive design */
@media (max-width: 400px) {
  .keyboard-btn {
    width: 50px;
    height: 50px;
    font-size: 1.3rem;
  }
  
  .keyboard-row {
    gap: 8px;
  }
}
</style>