# Create your views here.
from django.shortcuts import render_to_response
from django.template.context import RequestContext

def browser_test(request):
    return render_to_response('browser_test.html', context_instance=RequestContext(request))

def index(request):
    return render_to_response('index.html', context_instance=RequestContext(request))

def google_map(request):
    return render_to_response('map.html', context_instance=RequestContext(request))

