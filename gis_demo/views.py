# Create your views here.
from django.contrib.gis.geos.collections import GeometryCollection
from django.shortcuts import render_to_response
from django.template.context import RequestContext

import json

from string import Template

from models import OhioCounties

def index(request):
    return render_to_response('index.html', context_instance=RequestContext(request))

def json_test(request):

    counties = OhioCounties.objects.all()

    #county = OhioCounties.objects.get(gid=1)

    county_geom = [county.the_geom for county in counties]

    collection = GeometryCollection(county_geom)

    return render_to_response('json/base.json', {'json': collection.json}, context_instance=RequestContext(request))
    #return render_to_response('json/base.json', {'json': county.the_geom.json}, context_instance=RequestContext(request))

def county_list(request):

    counties = OhioCounties.objects.all()

    counties = map(lambda county: {str(county.name) : int(county.gid)}, counties)

    county_list = json.dumps(counties)

    return render_to_response('json/base.json', {'json': county_list}, context_instance=RequestContext(request))

def county(request, county_id):

    county = OhioCounties.objects.get(pk=county_id)

    response = json.dumps({'name' : str(county.name), 'gid' : int(county.gid), 'the_geom' : json.loads(county.the_geom.json)})

    return render_to_response('json/base.json', {'json': response}, context_instance=RequestContext(request))

