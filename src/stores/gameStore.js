import { defineStore } from 'pinia';

export const useGameStore = defineStore('game', {
  state: () => ({
    currentCountryIndex: 0,
    currentLandmarkIndex: 0,
    tickets: 0,
    coins: 0,
    countries: [
      { name: "France", landmarks: ["Eiffel Tower", "Louvre Museum", "Notre Dame", "Mont Saint-Michel", "Palace of Versailles"] },
      { name: "Spain", landmarks: ["Sagrada Familia", "Alhambra", "Park Güell", "Seville Cathedral", "Plaza Mayor"] },
      { name: "USA", landmarks: ["Statue of Liberty", "Grand Canyon", "Times Square", "Golden Gate Bridge", "Yellowstone National Park"] },
      { name: "China", landmarks: ["Great Wall", "Forbidden City", "Terracotta Army", "Shanghai Tower", "Guilin Mountains"] },
      { name: "Italy", landmarks: ["Colosseum", "Leaning Tower of Pisa", "Venice Canals", "Pantheon", "Amalfi Coast"] },
      { name: "Turkey", landmarks: ["Hagia Sophia", "Blue Mosque", "Cappadocia", "Pamukkale", "Ephesus"] },
      { name: "Mexico", landmarks: ["Chichen Itza", "Teotihuacan", "Cenotes", "Frida Kahlo Museum", "Cabo Arch"] },
      { name: "Germany", landmarks: ["Brandenburg Gate", "Neuschwanstein Castle", "Cologne Cathedral", "Berlin Wall", "Black Forest"] },
      { name: "Thailand", landmarks: ["Grand Palace", "Wat Arun", "Phi Phi Islands", "Ayutthaya", "Floating Markets"] },
      { name: "UK", landmarks: ["Big Ben", "Stonehenge", "Tower of London", "Buckingham Palace", "Edinburgh Castle"] },
      { name: "Japan", landmarks: ["Mount Fuji", "Tokyo Tower", "Fushimi Inari Shrine", "Himeji Castle", "Shibuya Crossing"] },
      { name: "Austria", landmarks: ["Schönbrunn Palace", "Hallstatt", "Belvedere Palace", "Melk Abbey", "Grossglockner"] },
      { name: "Greece", landmarks: ["Acropolis", "Santorini", "Delphi Ruins", "Meteora", "Mykonos Windmills"] },
      { name: "Malaysia", landmarks: ["Petronas Towers", "Langkawi Sky Bridge", "Batu Caves", "George Town", "Kinabalu Park"] },
      { name: "Russia", landmarks: ["Red Square", "Saint Basil’s Cathedral", "Hermitage Museum", "Lake Baikal", "Trans-Siberian Railway"] },
      { name: "Canada", landmarks: ["Niagara Falls", "Banff National Park", "CN Tower", "Old Quebec", "Stanley Park"] },
      { name: "Poland", landmarks: ["Wawel Castle", "Auschwitz", "Malbork Castle", "Warsaw Old Town", "Tatra Mountains"] },
      { name: "Netherlands", landmarks: ["Anne Frank House", "Rijksmuseum", "Keukenhof", "Windmills of Kinderdijk", "Van Gogh Museum"] },
      { name: "Portugal", landmarks: ["Belém Tower", "Pena Palace", "Douro Valley", "São Jorge Castle", "Benagil Cave"] },
      { name: "South Korea", landmarks: ["Gyeongbokgung Palace", "N Seoul Tower", "Bukchon Hanok Village", "Jeju Island", "Busan Beaches"] },
    ],
  }),
  actions: {
    addTicket() {
      this.tickets++;

      // Move to the next landmark every 5 tickets
      if (this.tickets >= 5) {
        this.tickets = 0;
        this.currentLandmarkIndex++;

        // If the player finishes all 5 landmarks, move to the next country
        if (this.currentLandmarkIndex >= 5) {
          this.currentLandmarkIndex = 0;
          this.currentCountryIndex++;

          // If the player reaches the last country, cycle back to the first
          if (this.currentCountryIndex >= this.countries.length) {
            this.currentCountryIndex = 0;
          }
        }
      }
    },
  },
});
