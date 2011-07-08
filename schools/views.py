# Create your views here.
import json
from django.shortcuts import render_to_response
from django.template.context import RequestContext
from models import GiseduSchoolType, GiseduSchool

def school_type_list(request):
    types = GiseduSchoolType.objects.all()
    types = map(lambda type: str(type.school_type), types)
    types.sort()
    type_list = json.dumps(types)
    return render_to_response('json/base.json', {'json' : type_list}, context_instance=RequestContext(request))

def school_list_by_typename(request, type_name):
    schools = GiseduSchool.objects.filter(school_type__school_type=type_name)
    school_names = map(lambda school: str(school.org.org_nm), schools)
    school_ids = map(lambda school: school.gid, schools)
    schools = dict(zip(school_ids, school_names))
    return render_to_response('json/base.json', {'json' : json.dumps(schools)}, context_instance=RequestContext(request))

def schools_by_type(request, type_name):
    schools = GiseduSchool.objects.filter(school_type__school_type=type_name)
    schools = map(lambda school: {"name": str(school.org.org_nm), "gid" : int(school.gid), "org_gid": int(school.org.gid)}, schools)
    schools.sort()
    school_list = json.dumps(schools)
    return render_to_response('json/base.json', {'json' : school_list}, context_instance=RequestContext(request))

def school_geom(request, school_id):
    school = GiseduSchool.objects.get(pk=school_id)
    return render_to_response('json/base.json', {'json': school.org.the_geom.json}, context_instance=RequestContext(request))

def school_infobox(request, school_id):
    school = GiseduSchool.objects.get(pk=school_id)
    return render_to_response('edu_org_info.html', {'org_name' : school.org.org_nm, 'address': school.org.address}, context_instance=RequestContext(request))