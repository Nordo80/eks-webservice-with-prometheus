from flask import Flask, render_template, Response
import os
import pytz
from datetime import datetime, timezone
from prometheus_client import Counter

PEOPLE_FOLDER = os.path.join('static', 'people_photo')

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = PEOPLE_FOLDER
colombo_counter = 0
gandalf_counter = 0

@app.route('/')
def main_page():
    message = """<xmp>
        Hello there!
        I hope you enjoy browsing my website.

        Here you can find two endpoints:
        * /metrics - shows total requests count of main endpoints
        * /colombo – displays the current time in Colombo City
        * /gandalf – I’ll keep what’s there a secret for now. Just click it and you’ll find out :)

        Enjoy!</xmp>"""
    return message

@app.route('/metrics')
def show_metrics():
    metrics = render_template('metrics_index.html', colombo_counter=colombo_counter, gandalf_counter=gandalf_counter)
    return Response(metrics, mimetype='text/plain')

@app.route('/colombo')
def snow_colombo():
    global colombo_counter
    colombo_counter += 1
    tz = pytz.timezone('Asia/Colombo')
    return "Time in Colombo City is " + datetime.now(tz).strftime("%I:%M%p")

@app.route('/gandalf')
def show_index():
    global gandalf_counter
    gandalf_counter += 1
    full_filename = os.path.join(app.config['UPLOAD_FOLDER'], 'gandalf-laughing.gif')
    return render_template("gandalf_index.html", user_image = full_filename)
