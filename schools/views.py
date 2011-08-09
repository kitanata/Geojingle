# Create your views here.
import json
from django.shortcuts import render_to_response
from django.template.context import RequestContext
from models import GiseduSchoolType, GiseduSchool
from schools.models import SchoolItc, SchoolAreaClassification

def school_type_list(request):
    types = GiseduSchoolType.objects.all()
    type_names = map(lambda type: str(type.school_type), types)
    type_ids = map(lambda type: type.gid, types)
    types = dict(zip(type_names, type_ids))
    return render_to_response('json/base.json', {'json' : json.dumps(types)}, context_instance=RequestContext(request))

def school_itc_list(request):
    itcs = SchoolItc.objects.all()
    itc_names = map(lambda itc: str(itc.itc), itcs)
    itc_ids = map(lambda itc: itc.gid, itcs)
    itcs = dict(zip(itc_names, itc_ids))
    return render_to_response('json/base.json', {'json' : json.dumps(itcs)}, context_instance=RequestContext(request))

def school_ode_list(request):
    classes = SchoolAreaClassification.objects.all()
    ode_names = map(lambda cls: cls.classification, classes)
    ode_ids = map(lambda cls: cls.gid, classes)
    classes = dict(zip(ode_names, ode_ids))
    return render_to_response('json/base.json', {'json' : json.dumps(classes)}, context_instance=RequestContext(request))

def school_list_by_typename(request, type_name):
    schools = GiseduSchool.objects.filter(school_type__school_type=type_name)
    school_names = map(lambda school: str(school.school_name), schools)
    school_ids = map(lambda school: school.gid, schools)
    schools = dict(zip(school_ids, school_names))
    return render_to_response('json/base.json', {'json' : json.dumps(schools)}, context_instance=RequestContext(request))

def schools_by_type(request, type_name):
    schools = GiseduSchool.objects.filter(school_type__school_type=type_name)
    schools = map(lambda school: {"name": str(school.school_name), "gid" : int(school.gid), "org_gid": int(school.gid)}, schools)
    schools.sort()
    school_list = json.dumps(schools)
    return render_to_response('json/base.json', {'json' : school_list}, context_instance=RequestContext(request))

def school_geom(request, school_id):
    school = GiseduSchool.objects.get(pk=school_id)
    return render_to_response('json/base.json', {'json': school.the_geom.json}, context_instance=RequestContext(request))

def school_infobox(request, school_id):
    school = GiseduSchool.objects.get(pk=school_id)
    return render_to_response('edu_org_info.html', {'org_name' : school.school_name, 'address': school.address}, context_instance=RequestContext(request))