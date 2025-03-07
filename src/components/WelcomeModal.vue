<template>
  <v-dialog v-model="dialogVisible" max-width="500" persistent>
    <v-card class="welcome-card">
      <v-img src="https://placehold.co/500x200/1abc9c/ffffff?text=Math+Travel+Adventure" height="200" cover></v-img>
      
      <v-card-title class="text-h5 font-weight-bold">
        Welcome to Math Travel Adventure!
      </v-card-title>
      
      <v-card-text>
        <p class="mb-4">
          Journey around the world, exploring famous landmarks while improving your math skills!
        </p>
        
        <v-stepper v-model="currentStep" class="welcome-stepper">
          <v-stepper-header>
            <v-stepper-item value="1" title="Game"></v-stepper-item>
            <v-divider></v-divider>
            <v-stepper-item value="2" title="Travel"></v-stepper-item>
            <v-divider></v-divider>
            <v-stepper-item value="3" title="Power-ups"></v-stepper-item>
          </v-stepper-header>
          
          <v-stepper-window>
            <v-stepper-window-item value="1">
              <div class="pa-4">
                <h3 class="text-h6 mb-2">How to Play</h3>
                <p>Solve math problems to earn tickets. Each correct answer gives you 1 ticket.</p>
                <div class="d-flex align-center justify-center my-4">
                  <span class="text-h5 mr-2">5 + 3 = ?</span>
                  <v-icon color="success" size="large">mdi-arrow-right</v-icon>
                  <span class="text-h5 ml-2">8</span>
                </div>
                <p>Choose from three difficulty levels: Easy, Medium, and Hard.</p>
                <p>The harder the problems, the more rewards you'll earn!</p>
              </div>
            </v-stepper-window-item>
            
            <v-stepper-window-item value="2">
              <div class="pa-4">
                <h3 class="text-h6 mb-2">Travel the World</h3>
                <p>Every 5 tickets lets you move to a new landmark.</p>
                <p>Visit 5 landmarks to travel to a new country!</p>
                <div class="d-flex justify-center my-4">
                  <div class="landmark-progress">
                    <div class="landmark-icon" v-for="i in 5" :key="i">
                      <v-icon :icon="i === 1 ? 'mdi-map-marker' : 'mdi-map-marker-outline'" 
                        :color="i === 1 ? 'red' : 'grey'"
                        size="large"></v-icon>
                    </div>
                    <div class="landmark-line"></div>
                  </div>
                </div>
                <p>Earn 10 coins each time you complete a country!</p>
              </div>
            </v-stepper-window-item>
            
            <v-stepper-window-item value="3">
              <div class="pa-4">
                <h3 class="text-h6 mb-2">Power-ups</h3>
                <p>Use coins to buy helpful power-ups:</p>
                
                <v-list>
                  <v-list-item>
                    <template v-slot:prepend>
                      <v-icon color="blue" icon="mdi-clock-outline"></v-icon>
                    </template>
                    <v-list-item-title>Time Freeze</v-list-item-title>
                    <v-list-item-subtitle>Stops the timer for one problem</v-list-item-subtitle>
                  </v-list-item>
                  
                  <v-list-item>
                    <template v-slot:prepend>
                      <v-icon color="green" icon="mdi-lightbulb-outline"></v-icon>
                    </template>
                    <v-list-item-title>Hint</v-list-item-title>
                    <v-list-item-subtitle>Gives you a helpful hint</v-list-item-subtitle>
                  </v-list-item>
                  
                  <v-list-item>
                    <template v-slot:prepend>
                      <v-icon color="purple" icon="mdi-star-outline"></v-icon>
                    </template>
                    <v-list-item-title>Double Points</v-list-item-title>
                    <v-list-item-subtitle>Doubles tickets for one problem</v-list-item-subtitle>
                  </v-list-item>
                </v-list>
              </div>
            </v-stepper-window-item>
          </v-stepper-window>
        </v-stepper>
      </v-card-text>
      
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn
          v-if="currentStep !== '1'"
          variant="text"
          @click="currentStep = String(parseInt(currentStep) - 1)"
        >
          Back
        </v-btn>
        
        <v-btn
          v-if="currentStep !== '3'"
          color="primary"
          variant="text"
          @click="currentStep = String(parseInt(currentStep) + 1)"
        >
          Next
        </v-btn>
        
        <v-btn
          v-else
          color="primary"
          variant="text"
          @click="startGame"
        >
          Start Adventure!
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue';

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['update:modelValue']);

const currentStep = ref('1');
const dialogVisible = ref(false);

// Sync with parent's v-model
watch(() => props.modelValue, (newValue) => {
  dialogVisible.value = newValue;
});

watch(dialogVisible, (newValue) => {
  emit('update:modelValue', newValue);
});

function startGame() {
  // Set a flag in localStorage to know the user has seen the welcome screen
  localStorage.setItem('hasSeenWelcome', 'true');
  dialogVisible.value = false;
}

onMounted(() => {
  // Check if this is the first time visiting
  if (!localStorage.getItem('hasSeenWelcome')) {
    dialogVisible.value = true;
  }
});
</script>

<style scoped>
.welcome-card {
  border-radius: 16px;
  overflow: hidden;
}

.welcome-stepper {
  background: transparent;
}

.landmark-progress {
  display: flex;
  position: relative;
  justify-content: space-between;
  width: 90%;
  padding: 10px 0;
}

.landmark-line {
  position: absolute;
  top: 50%;
  left: 10%;
  right: 10%;
  height: 2px;
  background-color: #ccc;
  z-index: -1;
}

.landmark-icon {
  background: white;
  border-radius: 50%;
  z-index: 1;
}
</style>