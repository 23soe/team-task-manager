<script setup>
import { ref } from 'vue'

const email = ref('')
const password = ref('')

const handleLogin = () => {
    console.log('ログインボタンclick!', email.value, password.value)
    //以降、Axiosでバックエンドにログイン要求を送信
}
</script>

<template>
    <div class="login-view">
        <h1>Login</h1>
        <form @submit.prevent="handleLogin">
            <input v-model="email" type="email" placeholder="メールアドレスを入力してください。  " required />
            <input v-model="password" type="password" placeholder="パスワードを入力してください。  " required />
            <button type="submit" class="login-button">ログイン</button>
            <router-link to="/signup" class="signup-button">
                サインアップ
            </router-link>
        </form>
    </div>
</template>

<style scoped>
.login-button {
  display: inline-block;
  padding: 10px 20px;
  background-color: #4CAF50;
  color: white;
  text-decoration: none;
  border-radius: 8px;
  text-align: center;
}
.signup-button {
  display: inline-block;
  padding: 10px 20px;
  background-color: #1a1a1a;
  color: white;
  text-decoration: none;
  border-radius: 8px;
  text-align: center;
}
</style>