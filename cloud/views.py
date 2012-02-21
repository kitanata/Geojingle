# Create your views here.
from datetime import datetime
import json
from django.http import HttpResponse, HttpResponseNotFound
from django.shortcuts import get_object_or_404
from cloud.models import CloudProjectStorageItem

def project_list(request):
    """ Returns a list of projects stored on 
    the server by the currently connected user """
    if request.user.is_authenticated:
        project_items = CloudProjectStorageItem.objects.filter(
                        user=request.user)
        list_data = dict([(project.name, str(project.last_modified))
                            for project in project_items])

        return HttpResponse(json.dumps(list_data), 
                mimetype='application/json')

    return HttpResponseNotFound()

def project(request, project_name):
    """ An entry point for ReST saving/loading of projects based on request method """
    if request.method ==  'POST':
        return save_project(request, project_name)
    elif request.method == 'GET' or request.method == 'HEAD':
        return open_project(request, project_name)

def save_project(request, project_name):
    """ Save the project to the server with information given in request by JSON """
    saveData = json.loads(request.raw_post_data)
    print("Save Data ", saveData)
    print("Dump Data ", json.dumps(saveData))

    try:
        curProject = CloudProjectStorageItem.objects.get(user=request.user, name=project_name)
        curProject.last_modified = datetime.now()
        curProject.saved_data = json.dumps(saveData)
        curProject.save()
    except CloudProjectStorageItem.DoesNotExist:
        newProject = CloudProjectStorageItem()
        newProject.last_modified = datetime.now()
        newProject.user = request.user
        newProject.saved_data = json.dumps(saveData)
        newProject.name = project_name
        newProject.save()
    except Exception as e:
        print(str(e))

    return HttpResponse(mimetype='application/json')

def open_project(request, project_name):
    """ Opens the project from the server of a given name """
    print("user is " + str(request.user))
    print("project_name is " + str(project_name))

    project = get_object_or_404(CloudProjectStorageItem, user=request.user, name=project_name)

    return HttpResponse(project.saved_data, mimetype='application/json')
