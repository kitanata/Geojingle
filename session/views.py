##################################################
# session/views.py
# SCAuthExample
#
# Created by Saikat Chakrabarti on April 7, 2010.
#
# See LICENSE file for license information.
##################################################
from datetime import timedelta
import json
from django.contrib.auth import authenticate, login, logout

from django.http import HttpResponseNotAllowed, HttpResponseNotFound, HttpResponse, HttpResponseForbidden
from django.utils import simplejson
from django.views.decorators.csrf import csrf_exempt
from django.core.context_processors import csrf

@csrf_exempt
def session_request(request):
    print("Session Request Called")
    if request.method ==  'POST':
        return login_user(request)
    if request.method == 'DELETE':
        return logout_user(request)
    elif request.method == 'GET' or request.method == 'HEAD':
        return is_logged_in(request)
    else:
        return HttpResponseNotAllowed(['POST', 'GET', 'DELETE'])

@csrf_exempt
def login_user(request):
    jsonObj = simplejson.loads(request.raw_post_data)
    username = jsonObj['username']
    password = jsonObj['password']
    remember = jsonObj['remember']

    user = authenticate(username=username, password=password)

    if user is not None:
        if user.is_active:
            login(request, user)

            if remember:
                sessionLength = timedelta(days=10)
                request.session.set_expiry(sessionLength)

            response = {'csrf_token': str(csrf(request)['csrf_token']), 'username' : username}
            return HttpResponse(json.dumps(response), mimetype='application/json')

    return HttpResponseForbidden(mimetype = 'application/json')

@csrf_exempt
def is_logged_in(request):
    print("Is Logged In Called")
    if request.user.is_authenticated():
        response = {'csrf_token': str(csrf(request)['csrf_token']), 'username' : request.user.username}
        return HttpResponse(json.dumps(response), mimetype='application/json')

    return HttpResponseNotFound(mimetype = 'application/json')

def logout_user(request):
    logout(request)
    return HttpResponse(mimetype='application/json')
