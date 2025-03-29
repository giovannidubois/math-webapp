import { defineStore } from 'pinia';

export const useGameStore = defineStore('game', {
  state: () => ({
    currentCountryIndex: 0,
    currentLandmarkIndex: 0,
    tickets: 0,
    coins: 0,
    difficulty: 'medium', // 'easy', 'medium', 'hard'
    activePowerUps: {
      timeFreeze: false,
      hint: false,
      doublePoints: false
    },
    powerUpInventory: {
      timeFreeze: 0,
      hint: 0,
      doublePoints: 0
    },
    avatar: 'traveler1', // Default avatar
    streakCount: 0, // Tracks consecutive correct answers
    imageExtension: 'png', // Default extension to try first
    
    // New properties for enhanced learning
    questionHistory: [], // Stores recent questions to avoid repeats
    reviewQueue: [], // Stores questions the player got wrong
    operatorMastery: {
      '+': { level: 1, correct: 0, incorrect: 0 },
      '-': { level: 1, correct: 0, incorrect: 0 },
      '×': { level: 0, correct: 0, incorrect: 0 },
      '÷': { level: 0, correct: 0, incorrect: 0 }
    },
    consecutiveCorrect: 0, // Track consecutive correct answers for difficulty adjustment
    consecutiveIncorrect: 0, // Track consecutive incorrect answers for difficulty adjustment
    totalQuestionsAnswered: 0, // Track total questions for analytics
    adaptiveDifficulty: 'easy', // Initial adaptive difficulty
    
    countries: [
      { 
        name: "France", 
        id: "france",
        landmarks: [
          "Eiffel Tower", 
          "Louvre Museum", 
          "Notre Dame", 
          "Mont Saint-Michel", 
          "Palace of Versailles"
        ] 
      },
      { 
        name: "Spain", 
        id: "spain",
        landmarks: [
          "Sagrada Familia", 
          "Alhambra", 
          "Park Güell", 
          "Seville Cathedral", 
          "Plaza Mayor"
        ] 
      },
      // Keep other countries as they were
      { name: "USA", id: "usa", landmarks: ["Statue of Liberty", "Grand Canyon", "Times Square", "Golden Gate Bridge", "Yellowstone National Park"] },
      { name: "China", id: "china", landmarks: ["Great Wall", "Forbidden City", "Terracotta Army", "Shanghai Tower", "Guilin Mountains"] },
      { name: "Italy", id: "italy", landmarks: ["Colosseum", "Leaning Tower of Pisa", "Venice Canals", "Pantheon", "Amalfi Coast"] },
      { name: "Turkey", id: "turkey", landmarks: ["Hagia Sophia", "Blue Mosque", "Cappadocia", "Pamukkale", "Ephesus"] },
      { name: "Mexico", id: "mexico", landmarks: ["Chichen Itza", "Teotihuacan", "Cenotes", "Frida Kahlo Museum", "Cabo Arch"] },
      { name: "Germany", id: "germany", landmarks: ["Brandenburg Gate", "Neuschwanstein Castle", "Cologne Cathedral", "Berlin Wall", "Black Forest"] },
      { name: "Thailand", id: "thailand", landmarks: ["Grand Palace", "Wat Arun", "Phi Phi Islands", "Ayutthaya", "Floating Markets"] },
      { name: "UK", id: "uk", landmarks: ["Big Ben", "Stonehenge", "Tower of London", "Buckingham Palace", "Edinburgh Castle"] },
      { name: "Japan", id: "japan", landmarks: ["Mount Fuji", "Tokyo Tower", "Fushimi Inari Shrine", "Himeji Castle", "Shibuya Crossing"] },
      { name: "Austria", id: "austria", landmarks: ["Schönbrunn Palace", "Hallstatt", "Belvedere Palace", "Melk Abbey", "Grossglockner"] },
      { name: "Greece", id: "greece", landmarks: ["Acropolis", "Santorini", "Delphi Ruins", "Meteora", "Mykonos Windmills"] },
      { name: "Malaysia", id: "malaysia", landmarks: ["Petronas Towers", "Langkawi Sky Bridge", "Batu Caves", "George Town", "Kinabalu Park"] },
      { name: "Russia", id: "russia", landmarks: ["Red Square", "Saint Basil's Cathedral", "Hermitage Museum", "Lake Baikal", "Trans-Siberian Railway"] },
      { name: "Canada", id: "canada", landmarks: ["Niagara Falls", "Banff National Park", "CN Tower", "Old Quebec", "Stanley Park"] },
      { name: "Poland", id: "poland", landmarks: ["Wawel Castle", "Auschwitz", "Malbork Castle", "Warsaw Old Town", "Tatra Mountains"] },
      { name: "Netherlands", id: "netherlands", landmarks: ["Anne Frank House", "Rijksmuseum", "Keukenhof", "Windmills of Kinderdijk", "Van Gogh Museum"] },
      { name: "Portugal", id: "portugal", landmarks: ["Belém Tower", "Pena Palace", "Douro Valley", "São Jorge Castle", "Benagil Cave"] },
      { name: "South Korea", id: "south-korea", landmarks: ["Gyeongbokgung Palace", "N Seoul Tower", "Bukchon Hanok Village", "Jeju Island", "Busan Beaches"] },
    ],
  }),
  getters: {
    // Get the image path for the current landmark
    currentLandmarkImagePath() {
      const country = this.countries[this.currentCountryIndex];
      const landmark = country.landmarks[this.currentLandmarkIndex];
      
      // Convert landmark name to kebab-case for the filename
      const landmarkId = landmark
        .toLowerCase()
        .replace(/\s+/g, '-') // Replace spaces with hyphens
        .replace(/[^\w-]/g, ''); // Remove special characters
      
      // Generate the base path without extension
      const basePath = `/images/landmarks/${country.id}/${landmarkId}`;
      
      // Try to determine the right extension - in a real app, you'd check if the file exists
      // But for now, we'll use the current extension in state
      return `${basePath}.${this.imageExtension}`;
    },
    
    // Get available operators based on mastery levels
    availableOperators() {
      const operators = [];
      
      // Always include addition and subtraction
      operators.push('+', '-');
      
      // Include multiplication if mastery level is at least 1
      if (this.operatorMastery['×'].level >= 1) {
        operators.push('×');
      }
      
      // Include division if mastery level is at least 1
      if (this.operatorMastery['÷'].level >= 1) {
        operators.push('÷');
      }
      
      return operators;
    },
    
    // Get number range based on adaptive difficulty
    numberRange() {
      const progress = this.currentCountryIndex * 5 + this.currentLandmarkIndex;
      const baseRange = { min: 0, max: 10 };
      
      switch (this.adaptiveDifficulty) {
        case 'easy':
          return { min: 0, max: 10 };
        case 'medium':
          return { min: 0, max: 12 };
        case 'hard':
          return { min: 0, max: 20 };
        default:
          return baseRange;
      }
    },
    
    // Determine if we should show a review question
    shouldShowReviewQuestion() {
      // Show a review question every 5-10 questions if there are any in the queue
      return this.reviewQueue.length > 0 && this.totalQuestionsAnswered % Math.floor(Math.random() * 6 + 5) === 0;
    }
  },
  actions: {
    // Try to load an image with a different extension
    tryAlternateExtension() {
      // Toggle between png and jpg
      this.imageExtension = this.imageExtension === 'png' ? 'jpg' : 'png';
      console.log(`Trying with .${this.imageExtension} extension`);
      return this.currentLandmarkImagePath;
    },
    
    // Track a question in history and update mastery
    trackQuestion(question, isCorrect) {
      this.totalQuestionsAnswered++;
      
      // Create a unique key for the question
      const questionKey = `${question.num1}${question.operator}${question.num2}`;
      
      // Add to question history (limit to 30 questions)
      this.questionHistory.push(questionKey);
      if (this.questionHistory.length > 30) {
        this.questionHistory.shift();
      }
      
      // Update operator mastery
      if (isCorrect) {
        this.operatorMastery[question.operator].correct++;
        this.consecutiveCorrect++;
        this.consecutiveIncorrect = 0;
        
        // Check if we should level up this operator
        const mastery = this.operatorMastery[question.operator];
        if (mastery.correct >= (mastery.level + 1) * 5) {
          mastery.level++;
        }
      } else {
        this.operatorMastery[question.operator].incorrect++;
        this.consecutiveCorrect = 0;
        this.consecutiveIncorrect++;
        
        // Add the question to the review queue
        this.reviewQueue.push({
          ...question,
          timestamp: Date.now()
        });
        
        // Limit review queue to 20 questions
        if (this.reviewQueue.length > 20) {
          this.reviewQueue.shift();
        }
      }
      
      // Update adaptive difficulty based on performance
      this.updateAdaptiveDifficulty();
      
      // Save game state
      this.saveGameState();
    },
    
    // Update adaptive difficulty based on performance
    updateAdaptiveDifficulty() {
      // Increase difficulty if player gets 5 consecutive correct answers
      if (this.consecutiveCorrect >= 5) {
        if (this.adaptiveDifficulty === 'easy') {
          this.adaptiveDifficulty = 'medium';
          this.consecutiveCorrect = 0;
        } else if (this.adaptiveDifficulty === 'medium' && this.currentCountryIndex >= 5) {
          this.adaptiveDifficulty = 'hard';
          this.consecutiveCorrect = 0;
        }
      }
      
      // Decrease difficulty if player gets 3 consecutive incorrect answers
      if (this.consecutiveIncorrect >= 3) {
        if (this.adaptiveDifficulty === 'hard') {
          this.adaptiveDifficulty = 'medium';
          this.consecutiveIncorrect = 0;
        } else if (this.adaptiveDifficulty === 'medium') {
          this.adaptiveDifficulty = 'easy';
          this.consecutiveIncorrect = 0;
        }
      }
    },
    
    // Get a review question from the queue
    getReviewQuestion() {
      if (this.reviewQueue.length === 0) return null;
      
      // Sort review queue by timestamp (oldest first)
      const sortedQueue = [...this.reviewQueue].sort((a, b) => a.timestamp - b.timestamp);
      
      // Get the oldest question
      const question = sortedQueue[0];
      
      // Remove from review queue
      this.reviewQueue = this.reviewQueue.filter(q => 
        q.num1 !== question.num1 || q.operator !== question.operator || q.num2 !== question.num2
      );
      
      // Return just the question data
      return {
        num1: question.num1,
        num2: question.num2,
        operator: question.operator
      };
    },
    
    // Check if a question is in recent history
    isQuestionInHistory(question) {
      const questionKey = `${question.num1}${question.operator}${question.num2}`;
      return this.questionHistory.includes(questionKey);
    },
    
    // Get learning hint for a specific question
    getLearningHint(question) {
      const { num1, num2, operator } = question;
      
      switch (operator) {
        case '+':
          if (num1 === 0 || num2 === 0) {
            return "Adding zero to any number gives the same number.";
          } else if (num1 === num2) {
            return `${num1} + ${num1} is the same as ${num1} × 2.`;
          } else {
            return `Try breaking it down: ${num1} + ${num2} = ${num1} + ${Math.floor(num2/2)} + ${num2 - Math.floor(num2/2)}`;
          }
        case '-':
          if (num2 === 0) {
            return "Subtracting zero from any number gives the same number.";
          } else if (num1 === num2) {
            return "Any number minus itself equals zero.";
          } else {
            return `Think of it as: ${num1} - ${num2} = ? means ${num2} + ? = ${num1}`;
          }
        case '×':
          if (num1 === 0 || num2 === 0) {
            return "Any number multiplied by zero equals zero.";
          } else if (num1 === 1 || num2 === 1) {
            return "Multiplying by 1 gives the same number.";
          } else if (num1 === 10 || num2 === 10) {
            return "To multiply by 10, add a zero to the end of the number.";
          } else if (num1 === 5 || num2 === 5) {
            return "To multiply by 5, multiply by 10 and divide by 2.";
          } else if (num1 === 9 || num2 === 9) {
            return "For 9 times tables, the digits always add up to 9.";
          } else {
            return `Break it down: ${num1} × ${num2} = ${num1} × ${num2-1} + ${num1}`;
          }
        case '÷':
          if (num1 === 0) {
            return "Zero divided by any number (except 0) equals zero.";
          } else if (num2 === 1) {
            return "Any number divided by 1 equals itself.";
          } else if (num1 === num2) {
            return "Any number divided by itself equals 1.";
          } else {
            return `Think of it as: ${num1} ÷ ${num2} = ? means ${num2} × ? = ${num1}`;
          }
        default:
          return "Think step by step.";
      }
    },
    
    addTicket(correctAnswer = true) {
      if (correctAnswer) {
        // Increment streak for consecutive correct answers
        this.streakCount++;
        
        // Award extra coin for every 5 consecutive correct answers
        if (this.streakCount % 5 === 0) {
          this.coins++;
        }
        
        // Add tickets based on difficulty and power-ups
        let ticketsToAdd = 1;
        
        // Double points power-up
        if (this.activePowerUps.doublePoints) {
          ticketsToAdd *= 2;
          this.activePowerUps.doublePoints = false; // Power-up is used
        }
        
        // Difficulty bonus
        if (this.difficulty === 'hard') {
          ticketsToAdd += 1; // Extra ticket for hard difficulty
        }
        
        this.tickets += ticketsToAdd;

        // Move to the next landmark every 5 tickets
        if (this.tickets >= 5) {
          this.tickets = 0;
          this.currentLandmarkIndex++;

          // If the player finishes all 5 landmarks, move to the next country
          if (this.currentLandmarkIndex >= 5) {
            this.currentLandmarkIndex = 0;
            this.coins += 10; // Award coins for completing a country
            this.currentCountryIndex++;

            // If the player reaches the last country, cycle back to the first
            if (this.currentCountryIndex >= this.countries.length) {
              this.currentCountryIndex = 0;
            }
          }
        }
      } else {
        // Reset streak for incorrect answers
        this.streakCount = 0;
      }
      
      // Save game state
      this.saveGameState();
    },
    
    usePowerUp(powerUp) {
      if (this.powerUpInventory[powerUp] > 0) {
        this.powerUpInventory[powerUp]--;
        this.activePowerUps[powerUp] = true;
        this.saveGameState();
        return true;
      }
      return false;
    },
    
    buyPowerUp(powerUp) {
      const costs = {
        timeFreeze: 5,
        hint: 3,
        doublePoints: 8
      };
      
      if (this.coins >= costs[powerUp]) {
        this.coins -= costs[powerUp];
        this.powerUpInventory[powerUp]++;
        this.saveGameState();
        return true;
      }
      return false;
    },
    
    setDifficulty(level) {
      this.difficulty = level;
      this.saveGameState();
    },
    
    setAvatar(avatar) {
      this.avatar = avatar;
      this.saveGameState();
    },
    
    resetGame() {
      this.currentCountryIndex = 0;
      this.currentLandmarkIndex = 0;
      this.tickets = 0;
      this.coins = 0;
      this.streakCount = 0;
      this.saveGameState();
    },
    
    saveGameState() {
      localStorage.setItem('mathTravelGame', JSON.stringify({
        currentCountryIndex: this.currentCountryIndex,
        currentLandmarkIndex: this.currentLandmarkIndex,
        tickets: this.tickets,
        coins: this.coins,
        difficulty: this.difficulty,
        powerUpInventory: this.powerUpInventory,
        avatar: this.avatar,
        streakCount: this.streakCount,
        imageExtension: this.imageExtension,
        // Save new learning properties
        questionHistory: this.questionHistory,
        reviewQueue: this.reviewQueue,
        operatorMastery: this.operatorMastery,
        consecutiveCorrect: this.consecutiveCorrect,
        consecutiveIncorrect: this.consecutiveIncorrect,
        totalQuestionsAnswered: this.totalQuestionsAnswered,
        adaptiveDifficulty: this.adaptiveDifficulty
      }));
    },
    
    loadGameState() {
      const savedState = localStorage.getItem('mathTravelGame');
      if (savedState) {
        const parsedState = JSON.parse(savedState);
        this.currentCountryIndex = parsedState.currentCountryIndex || 0;
        this.currentLandmarkIndex = parsedState.currentLandmarkIndex || 0;
        this.tickets = parsedState.tickets || 0;
        this.coins = parsedState.coins || 0;
        this.difficulty = parsedState.difficulty || 'medium';
        this.powerUpInventory = parsedState.powerUpInventory || { timeFreeze: 0, hint: 0, doublePoints: 0 };
        this.avatar = parsedState.avatar || 'traveler1';
        this.streakCount = parsedState.streakCount || 0;
        this.imageExtension = parsedState.imageExtension || 'png';
        
        // Load new learning properties with fallbacks
        this.questionHistory = parsedState.questionHistory || [];
        this.reviewQueue = parsedState.reviewQueue || [];
        this.operatorMastery = parsedState.operatorMastery || {
          '+': { level: 1, correct: 0, incorrect: 0 },
          '-': { level: 1, correct: 0, incorrect: 0 },
          '×': { level: 0, correct: 0, incorrect: 0 },
          '÷': { level: 0, correct: 0, incorrect: 0 }
        };
        this.consecutiveCorrect = parsedState.consecutiveCorrect || 0;
        this.consecutiveIncorrect = parsedState.consecutiveIncorrect || 0;
        this.totalQuestionsAnswered = parsedState.totalQuestionsAnswered || 0;
        this.adaptiveDifficulty = parsedState.adaptiveDifficulty || 'easy';
      }
    }
  }
});