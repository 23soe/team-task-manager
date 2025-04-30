<template lang="pug">
div
  h2 チーム進捗一覧
  table
    thead
      tr
        th ユーザー名
        th 総タスク数
        th 完了タスク数
        th 進捗率
    tbody
      tr(v-for="member in membersProgress" :key="member.id")
        td {{ member.username }}
        td {{ member.total_tasks }}
        td {{ member.completed_tasks }}
        td
          .progress-container
            .progress-bar(:style="getProgressStyle(member.progress_rate)")
              span.progress-label {{ member.progress_rate }}%
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import api from '@/plugins/axios'

const props = defineProps({
  membersProgress: Array
})

const getProgressColor = (rate) => {
  if (rate >= 80) return '#4caf50' 
  if (rate >= 50) return '#ff9800' 
  if (rate >= 0) return '#ff9800' 
}


const getProgressStyle = (rate) => {
  return {
    width: rate + '%',
    backgroundColor: getProgressColor(rate)
  }
}

watch(() => props.workspaceId, () => {
  fetchMembersProgress()
})
</script>

<style scoped>
table {
  width: 100%;
  border-collapse: collapse;
}

th, td {
  padding: 12px;
  border: 1px solid #ddd;
  text-align: center;
}

.progress-container {
  position: relative;
  background-color: #f3f3f3;
  height: 20px;
  border-radius: 10px;
  overflow: hidden;
}

.progress-bar {
  height: 100%;
  transition: width 0.5s ease;
}

.progress-label {
  position: absolute;
  text-align: center;
  font-size: 12px;
  line-height: 20px;
  color: #fff;
}
</style>