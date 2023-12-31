from locust import HttpUser, task, between

class QuickstartUser(HttpUser):
    session_header=""
    wait_time = between(1, 2)
    def on_start(self):
        response = self.client.post("/mars/useraccount/v1/login", json={"user_name":"karaf", "password":"karaf"}, verify=False)
        self.session_header = {"Cookie": "marsGSessionId=" + response.headers["mars_g_session_id"]}
        #print("session_header", self.session_header)

    @task
    def getDevices(self):
        response = self.client.get("/mars/v1/devices", headers=self.session_header)
        #print(response.text)

    @task
    def getLinks(self):
        response = self.client.get("/mars/v1/links", headers=self.session_header)
        print(response.text)

    @task
    def getCluster(self):
        response = self.client.get("/mars/v1/cluster", headers=self.session_header)
        print(response.text)
