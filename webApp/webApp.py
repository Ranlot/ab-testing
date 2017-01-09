from flask import Flask
from flask import request, redirect
from flask import render_template, Response, jsonify
from scipy.stats import norm
from scipy import stats
from math import ceil
import numpy as np
import re
import smtplib
import statsmodels.stats.api as statsModels

app = Flask(__name__)

#!!! make sure it'll adapt to the relevant display !!!
#!!! save user input and calculated result to key-value store

#http://flask.theoryandpractice.org/?mux=3.&muy=3.7

class Parameters:

	significantPvalue = 0.95
        pvalueThreshold = 1 - significantPvalue

        powerValueHigher = 0.9 
        powerValueSmaller = 0.01

        minEvents = 1

	def __init__(self, pStar, pBaseLine):
        	self.pStar = pStar
        	self.pBaseLine = pBaseLine

    	def convertInput(self):
        	self.pStar = float(self.pStar)
        	self.pBaseLine = float(self.pBaseLine)

	def _normalDistrib(self, desiredSampleSize):
	        numbOfPoints = 50

		scaledSTD = np.sqrt(self.pStar * (1.0 - self.pStar) / float(desiredSampleSize))
		howManySigs = np.abs((self.pStar - self.pBaseLine) / scaledSTD)
		minRange, maxRange = max(0, self.pStar - 1.4*howManySigs*scaledSTD), min(1, self.pStar + 1.4*howManySigs*scaledSTD)

		plotPoints = np.linspace(minRange, maxRange, numbOfPoints)
		normPoints = [norm.pdf(x, loc=self.pStar, scale=scaledSTD) for x in plotPoints]

		plotData = [{'x':x[0], 'y':x[1]} for x in zip(plotPoints, normPoints)]
		morrisFlipIndex = min(range(numbOfPoints), key=lambda i: abs(plotData[i]['x'] - self.pBaseLine))
		
		return {'plotData':plotData, 'morrisFlipIndex':morrisFlipIndex}

        def cohenEffectSize(self):
                return 2 * (np.arcsin(np.sqrt(self.pStar)) - np.arcsin(np.sqrt(self.pBaseLine)))
        
        def normalPower(self, effectSize, nEvents):
                crit = stats.norm.isf(self.pvalueThreshold) #Inverse survival function sf defined as 1 - cdf
                return 100 * stats.norm.sf(crit - effectSize * np.sqrt(nEvents))

        #------------------------------------------------------------
        #checkout 7b1ca8e for the previous custom made implementation
        #------------------------------------------------------------
        def getResultSampleSize(self):
                effectSize = self.cohenEffectSize()
               
                def sampleSizeFinder(powerValue):
                    return int(statsModels.NormalIndPower().solve_power(effect_size=effectSize, power=powerValue, alpha=self.pvalueThreshold, alternative="larger") / 2.)

                sampleSize = sampleSizeFinder(self.powerValueHigher) if self.pStar > self.pBaseLine else sampleSizeFinder(self.powerValueSmaller) if self.pStar < self.pBaseLine else 5000
                validResults = [{'x':int(sampleSize), 'y':self.normalPower(effectSize, sampleSize)} for sampleSize in np.linspace(self.minEvents, sampleSize, num=50)]

                print 'Used pStar = %f ; pBaseLine = %f' % (self.pStar, self.pBaseLine)
                return {'data':validResults, 'sampleSizeCut':sampleSize, 'normalApprox':self._normalDistrib(sampleSize)}

	
@app.route('/res', methods=['POST'])
def getResult():
	paramsRequest = request.json
	pStar = paramsRequest['pStar']
	pBaseLine = paramsRequest['pBaseLine']
	params = Parameters(pStar, pBaseLine)
	if not re.match("^0?\.\d+$", pStar) or not re.match("^0?\.\d+$", pBaseLine):
		response = jsonify({'message':'Baseline or success rate incorrect.'})
		response.status_code = 400
		return response
	pStar = float(pStar);
	pBaseLine = float(pBaseLine);
	if not np.isclose(pStar, pBaseLine, rtol=0.4):
		response = jsonify({'message':"Rates are very different from each other, maybe AB tests are not what you need..."})
		response.status_code = 400
		return response
	if pStar == 0 or pBaseLine == 0:
		response = jsonify({'message':'Baseline and success rate must be strictly greater than 0.'})
		response.status_code = 400
		return response
	params.convertInput()
	return jsonify(params.getResultSampleSize())

@app.route('/')
def homePage():
	return app.send_static_file('index.html')

@app.route('/share')
def socialShare():
	social = request.args.get('social')
	send_email('sender@gmail.com', 'somePassword', 'receiver@gmail.com', 'Subject %s' % social, 'Body')
	return redirect(social, code=302)

def send_email(user, pwd, recipient, subject, body):
	gmail_user = user
	gmail_pwd = pwd
	FROM = user
	TO = recipient if type(recipient) is list else [recipient]
	SUBJECT = subject
	TEXT = body

	# Prepare actual message
	message = """From: %s\nTo: %s\nSubject: %s\n\n%s
	""" % (FROM, ", ".join(TO), SUBJECT, TEXT)
	try:
		server = smtplib.SMTP("smtp.gmail.com", 587)
		server.ehlo()
		server.starttls()
		server.login(gmail_user, gmail_pwd)
		server.sendmail(FROM, TO, message)
		server.close()
    	except:
		print 'failed to send mail'


if __name__ == "__main__":
	app.run()
	#app.run(host='0.0.0.0', port=5556, debug=True)

