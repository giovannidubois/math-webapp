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
        imageExtension: this.imageExtension
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
      }
    }
  }
});