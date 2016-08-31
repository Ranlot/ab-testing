from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
	return 'Prof. Linger is back... p-value convergence'

if __name__ == "__main__":
	app.run()

