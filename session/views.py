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
from django.contrib.auth.models import User

from django.http import HttpResponseNotAllowed, HttpResponseNotFound, HttpResponse, HttpResponseForbidden
from django.utils import simplejson
from django.views.decorators.csrf import csrf_exempt
from django.core.context_processors import csrf

@csrf_exempt
def session_request(request):
    """
    Depending on the request method this either logs a user in or out, or checks if the user is currently logged in.
        POST - Attempts to authenticate and log in a user
        DELETE - Attempts to log out the user stored in the current session
        GET or HEAD - Attempts to check if the user is currently logged in.
    """
    if request.method ==  'POST':
        return login_user(request)
    if request.method == 'DELETE':
        return logout_user(request)
    elif request.method == 'GET' or request.method == 'HEAD':
        return is_logged_in(request)
    else:
        return HttpResponseNotAllowed(['POST', 'GET', 'DELETE'])


@csrf_exempt
def register_request(request):
    """ On POST requests this attempts to register a new user with Gisedu."""
    if request.method == 'POST':
        return register_user(request)
    else:
        return HttpResponseNotAllowed(['POST'])



def handle_user_login(request, username, password, remember):
    user = authenticate(username=username, password=password)

    if user is not None and user.is_active:
        login(request, user)

        if remember:
            sessionLength = timedelta(days=10)
            request.session.set_expiry(sessionLength)

        response = {'csrf_token': str(csrf(request)['csrf_token']), 'username' : username}
        return HttpResponse(json.dumps(response), mimetype='application/json')

    return HttpResponseForbidden(mimetype = 'application/json')



@csrf_exempt
def login_user(request):
    jsonObj = simplejson.loads(request.raw_post_data)
    username = jsonObj['username']
    password = jsonObj['password']
    remember = jsonObj['remember']

    return handle_user_login(request, username, password, remember)


@csrf_exempt
def register_user(request):
    jsonObj = simplejson.loads(request.raw_post_data)

    username = jsonObj['username']
    password = jsonObj['password']
    email = jsonObj['email']
    remember = jsonObj['remember']

    try:
        newUser = User.objects.create_user(username, email, password)

        if newUser is not None:
            return handle_user_login(request, username, password, remember)
        else:
            return HttpResponseForbidden(mimetype = 'application/json')

    except Exception as e:
        return HttpResponseForbidden(mimetype = 'application/json')

    
@csrf_exempt
def check_user(request, username):
    """ Checks to see if a username is available for registering. """
    try:
        User.objects.get(username=username)
        return HttpResponseForbidden(mimetype = 'application/json')
    except User.DoesNotExist:
        return HttpResponse(mimetype='application/json')


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
