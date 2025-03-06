<template>
    <v-container class="keyboard-container">
      <div class="keyboard-row">
        <v-btn
          v-for="num in numbers"
          :key="num"
          class="keyboard-btn"
          color="white"
          @click="press(num)"
        >
          {{ num }}
        </v-btn>
  
        <v-btn class="keyboard-btn special-key" color="error" @click="backspace">
          ⌫
        </v-btn>
      </div>
    </v-container>
  </template>
  
  <script setup>
  import { ref, defineEmits } from 'vue';
  
  const numbers = ref([1, 2, 3, 4, 5, 6, 7, 8, 9, 0]);
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
    display: flex;
    justify-content: center;
    width: 100%;
    padding: 10px 0;
  }
  
  .keyboard-row {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 6px;
    max-width: 100%;
    padding: 10px;
  }
  
  .keyboard-btn {
    width: 45px;
    height: 45px;
    font-size: 1.2rem;
    border-radius: 8px;
    background: #2ecc71;
    color: white;
  }
  
  .special-key {
    background: #e74c3c;
  }
  </style>
  