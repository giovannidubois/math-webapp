import { createRouter, createWebHistory } from 'vue-router';
import GameView from '../views/GameView.vue';

const routes = [
  { path: '/', component: GameView },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
