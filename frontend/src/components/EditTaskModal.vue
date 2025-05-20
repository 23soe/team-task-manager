<template lang="pug">
.modal-overlay(v-if="visible")
  .modal-content
    h2 📝 タスク編集

    label.label-text ⬜ 目標
    input(v-model="task.title", placeholder="目標")

    label.label-text 📝 アクションプラン
    textarea(v-model="task.contents", placeholder="内容")

    label.label-text 📅 締切日
    input(type="date", v-model="task.dueDate")

    label.label-text
    .checkbox-group
    label.label-text.checkbox-item(v-for="user in props.users", :key="user.id")
      input(type="checkbox", :value="user.id", v-model="props.task.userIds")
      | 👤 {{ user.username }} 様


    label.label-text 🗂️
    select(v-model="task.category")
      option(value="") 選択してください
      option(value="業務") 業務
      option(value="組織") 組織
      option(value="勉強") 勉強

    .modal-actions
      button(@click="$emit('save')") 保存
      button(@click="$emit('cancel')") キャンセル

</template>

<script setup>
const props = defineProps({
  task: Object,
  users: Array,
  visible: Boolean
})

const emit = defineEmits(['save', 'cancel'])
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  display: flex;
  flex-direction: column;
  background: black;
  padding: 3vh;
  border-radius: 10px;
  width: 50vw;
  max-width: 90%;
  text-align:left;
  gap: 5px; 
}

.modal-actions {
  margin-top: 20px;
  display: flex;
  justify-content: space-between;
}

.checkbox-group {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.checkbox-item {
  display: flex;
  align-items: center;
}
</style>