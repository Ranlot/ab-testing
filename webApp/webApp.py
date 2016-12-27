from flask import Flask
from flask import request, redirect
from flask import render_template, Response, jsonify
from scipy.integrate import quad
from scipy.special import erfinv
from scipy.optimize import fsolve
from scipy.stats import norm
from math import ceil
import numpy as np
from itertools import takewhile
import re
import smtplib

app = Flask(__name__)

#!!! make sure it'll adapt to the relevant display !!!
#!!! save user input and calculated result to key-value store

#http://flask.theoryandpractice.org/?mux=3.&muy=3.7

class Parameters:

	significanPvalue = 0.95

	def __init__(self, pStar, pBaseLine):
        	self.pStar = pStar
        	self.pBaseLine = pBaseLine

    	def convertInput(self):
        	self.pStar = float(self.pStar)
        	self.pBaseLine = float(self.pBaseLine)

	def calculateN(self):
		return self.pStar + self.pBaseLine

	#define theoretical pdf with a closure
	def _theoreticalPDF(self, sampleSize):
		muZ = (self.pStar - self.pBaseLine) * np.sqrt(sampleSize / (self.pBaseLine * (1.0 - self.pBaseLine)))
		sigZ = np.sqrt( (self.pStar * (1.0 - self.pStar)) / (self.pBaseLine * (1.0 - self.pBaseLine)) )
		preFactor = np.exp( - muZ**2 / (2.0 * sigZ**2) ) / sigZ
		def closedPDF(p):
			return 100.0 * preFactor * np.exp((1.0 - 1.0 / sigZ**2) * erfinv(1 - 2*p)**2) * np.exp(-np.sqrt(2) * muZ / sigZ**2 * erfinv(1- 2*p))
        	return closedPDF

	def _integralCalculator(self, sampleSize):
		integralResult = quad(self._theoreticalPDF(sampleSize), self.significanPvalue, 1.0)
		return integralResult[0]

	def _setUp(self, sampleSize):
		return self._integralCalculator(sampleSize) - 95.0

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

	def getResultSampleSize(self):
		numbOfPlotPoints = 50
		minSampleSize, maxSampleSize = 10, 5000

		sampleSizes = (int(np.floor(sample)) for sample in np.linspace(minSampleSize, maxSampleSize, num=numbOfPlotPoints))
		plotResults = ({'x':sample, 'y':self._integralCalculator(sample)} for sample in sampleSizes)

		if self.pStar >= self.pBaseLine:
			validResults = list(takewhile(lambda plotResult: np.isfinite(plotResult['y']) and plotResult['y'] <= 99.0, plotResults))
		else:
			validResults = list(takewhile(lambda plotResult: np.isfinite(plotResult['y']) and plotResult['y'] >= 1.0, plotResults))	

		#print validResults

		numbOfNecessaryIterations = len(validResults)

		if numbOfNecessaryIterations < numbOfPlotPoints:

			if self.pStar >= self.pBaseLine:
				sampleSizeCut = min(validResults, key=lambda x: np.abs(x['y']-95))['x']
			else:
				sampleSizeCut = min(validResults, key=lambda x: np.abs(x['y']-1))['x']
	
			sampleSizeCut = int(np.floor(sampleSizeCut))
		else:
			if self.pStar >= self.pBaseLine:
				suggestedCut = fsolve(self._setUp, maxSampleSize)[0]
				#print suggestedCut
				verifyCloseness = np.isclose(self._integralCalculator(suggestedCut), 95.0, atol=0.1)

				if verifyCloseness:
					sampleSizeCut = int(np.floor(suggestedCut))
					sampleSizes = (int(np.floor(sample)) for sample in np.linspace(minSampleSize, sampleSizeCut, num=numbOfPlotPoints))
					plotResults = ({'x':sample, 'y':self._integralCalculator(sample)} for sample in sampleSizes)
					validResults = list(takewhile(lambda plotResult: np.isfinite(plotResult['y']) and plotResult['y'] <= 99.0, plotResults))
				else:
					sampleSizeCut = 2 * maxSampleSize

			else:
				sampleSizeCut = 2 * maxSampleSize

		normalApprox = self._normalDistrib(sampleSizeCut)
		#print normalApprox

		return {'data':validResults, 'sampleSizeCut':sampleSizeCut, 'normalApprox':self._normalDistrib(sampleSizeCut)}

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
		response = jsonify({'message':'This case is not interesting. Go away.'})
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

