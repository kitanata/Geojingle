# Create your views here.
import json
from django.shortcuts import render_to_response
from django.template.context import RequestContext
from organizations.models import GiseduOrgType, GiseduOrg

def org_geom(request, org_id):
    org = GiseduOrg.objects.get(pk=org_id)
    return render_to_response('json/base.json', {'json': org.the_geom.json}, context_instance=RequestContext(request))

def org_info(request, org_id):
    org = GiseduOrg.objects.get(pk=org_id)
    response = json.dumps({'gid' : int(org.gid), 'name' : org.org_nm, 'type' : org.org_type.org_type_name })
    return render_to_response('json/base.json', {'json': response}, context_instance=RequestContext(request))

def org_infobox(request, org_id):
    org = GiseduOrg.objects.get(pk=org_id)
    return render_to_response('edu_org_info.html', {'org_name' : org.org_nm, 'address': org.address}, context_instance=RequestContext(request))