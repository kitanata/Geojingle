# Create your views here.
from django.contrib.gis.geos.collections import GeometryCollection
from django.shortcuts import render_to_response
from django.template.context import RequestContext

from models import OhioCounties

def index(request):
    return render_to_response('index.html', context_instance=RequestContext(request))

def json(request):

    counties = OhioCounties.objects.all()

    #county = OhioCounties.objects.get(gid=1)

    county_geom = [county.the_geom for county in counties]

    collection = GeometryCollection(county_geom)

    return render_to_response('json/base.html', {'json': collection.json}, context_instance=RequestContext(request))
    #return render_to_response('json/base.html', {'json': county.the_geom.json}, context_instance=RequestContext(request))