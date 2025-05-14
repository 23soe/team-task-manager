from locust import HttpUser, task, between
import random

class ProgressTestUser(HttpUser):
    wait_time = between(1, 2)  # 요청 간 시간 랜덤

    @task
    def recalculate_parallel(self):
        self.client.post("/api/v1/task_progresses/recalculate", json={
            "workspace_id": random.randint(1, 3),  # 워크스페이스 ID 1~3 랜덤
            "parallel": True
        })

    @task
    def recalculate_sequential(self):
        self.client.post("/api/v1/task_progresses/recalculate", json={
            "workspace_id": random.randint(1, 3),
            "parallel": False
        })
