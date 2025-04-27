<script setup>
import { defineProps, defineEmits } from 'vue'

const props = defineProps({
  task: Object,
  getAssignees: Function,
  toggleStatus: Function,
})

const emit = defineEmits(['toggle-status'])

const toggle = () => {
  emit('toggle-status', task)
}
</script>

<template lang="pug">
div.task-card
  h3 {{ task.title }}
  p 担当者: {{ getAssignees(task.userIds) }}
  p 期限: {{ task.dueDate }}
  p {{ task.contents }}
  p カテゴリ: {{ task.category }}
  div.actions
    button(
        @click="$emit('edit', task)"
    ) 編集
    button(
        @click="$emit('request-delete', task)"
    ) 削除
    button(
      @click="toggleStatus(task)"
      :disabled="task.status === '完了'"
    ) {{ task.status }}
</template>

<style scoped>
.task-card {
  border: 1px solid #ccc;
  padding: 15px;
  margin-bottom: 15px;
  border-radius: 8px;
}

.actions {
  display: flex;
  gap: 10px;
  justify-content: center; 
}
</style> 