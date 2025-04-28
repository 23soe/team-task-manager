<script setup>
import { onMounted, ref} from 'vue'
import api from '@/plugins/axios'

const currentUser = ref(null)

onMounted(async () => {
  const token = localStorage.getItem('token')
  if (token) {
    try {
      const response = await api.get('/me')
      currentUser.value = response.data.user
      console.log('ログイン中ユーザー:', currentUser.value)
    }catch (error) {
      consoel.error('トークン無効または期限切れ', error)
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      windoe.location.href = '/login'
    }
  }
})
</script>

<template>
  <div id="app">
    <router-view></router-view>
  </div>
</template>

<style scoped>
.logo {
  height: 6em;
  padding: 1.5em;
  will-change: filter;
  transition: filter 300ms;
}
.logo:hover {
  filter: drop-shadow(0 0 2em #646cffaa);
}
.logo.vue:hover {
  filter: drop-shadow(0 0 2em #42b883aa);
}
</style>
