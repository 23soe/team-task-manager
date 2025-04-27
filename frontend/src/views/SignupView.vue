<script setup>
import { ref } from 'vue'

const name = ref('')
const organizations = ref([])
const organizationOptions = ['開発部', '営業部', '人事部', 'マーケティング部']
const email = ref('')
const password = ref('')

const handleSignup = () => {
    console.log('サインアップ送信!', { 
        name: name.value, 
        organization: organizations.value, 
        email: email.value, 
        password: password.value 
    })
}
</script>

<template>
    <div class="signup-vie">
        <h1>Sign up</h1>
        <form @submit.prevent="handleSignup">
            <input v-model="name" type="text" placeholder="名前" required/>
            <input v-model="email" type="email" placeholder="メールアドレス" required/>
            <input v-model="password" type="password" placeholder="パスワード" required/>
            <div class="signup-organiztion">
                <div v-for="org in organizationOptions" :key="org">
                    <label>
                        <input type="checkbox" :value="org" v-model="organizations" />
                        {{ org }}
                    </label>
                </div>
            </div>
            <button type="submit">サインアップ</button>
        </form>
    </div>
</template>

<style scoped>
.signup-organiztion {
    display: flex;
    flex-direction: row;
    gap: 20px;
    justify-content: center; 
}
</style>