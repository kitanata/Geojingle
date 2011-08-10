# Create your views here.
import json
from django.shortcuts import render_to_response
from django.template.context import RequestContext
from organizations.models import GiseduOrgType, GiseduOrg


def org_type_list(request):
    types = GiseduOrgType.objects.all()
    type_names = map(lambda type: str(type.org_type_name), types)
    type_ids = map(lambda type: int(type.gid), types)
    types = dict(zip(type_names, type_ids))
    return render_to_response('json/base.json', {'json' : json.dumps(types)}, context_instance=RequestContext(request))

def org_list_by_type(request, type):
    orgs = GiseduOrg.objects.filter(org_type=type)
    org_names = map(lambda org: str(org.org_nm), orgs)
    org_ids = map(lambda org: org.gid, orgs)
    orgs = dict(zip(org_ids, org_names))
    return render_to_response('json/base.json', {'json' : json.dumps(orgs)}, context_instance=RequestContext(request))

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