# Create your views here.
import json
from django.shortcuts import render_to_response, redirect
from django.template.context import RequestContext
from django.http import HttpResponseNotFound
from django.views.decorators.csrf import csrf_exempt
from filters.models import GiseduFilters
from point_objects.models import GiseduPointItem
from polygon_objects.models import GiseduPolygonItem

def browser_test(request):
    return render_to_response(
            'browser_test.html', context_instance=RequestContext(request))

def index(request):
    return redirect('/capp/index.html')

def google_map(request):
    return render_to_response(
            'map.html', context_instance=RequestContext(request))

@csrf_exempt
def geom_list(request):
    """
    Responds to a post request containing a list of Point or Polygon Item PKs 
    by returning a list corresponding to each item's geometry field stored in 
    the database.
    """

    if request.method != "POST":
        return HttpResponseNotFound(mimetype = 'application/json')

    jsonObj = json.loads(request.raw_post_data)

    for fltr, object_ids in jsonObj.iteritems():
        gis_filter = GiseduFilters.objects.get(pk=fltr)

        if gis_filter.filter_type == "POINT":
            objects = GiseduPointItem.objects.filter(filter=gis_filter)
            objects = objects.filter(pk__in=object_ids)
        elif gis_filter.filter_type == "POLYGON":
            objects = GiseduPolygonItem.objects.filter(filter=gis_filter)
            objects = objects.filter(pk__in=object_ids)

        jsonObj[fltr] = dict(
                [(x.pk, json.loads(x.the_geom.json)) for x in objects])

    return render_to_response(
            'json/base.json', 
            {'json': json.dumps(jsonObj)}, 
            context_instance=RequestContext(request))
