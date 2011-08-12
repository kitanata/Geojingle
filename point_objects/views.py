# Create your views here.
import json
from django.shortcuts import render_to_response
from django.template.context import RequestContext
from models import GiseduOrg, GiseduSchool, GiseduJointVocationalSchoolDistrict


def point_geom_by_type(request, data_type, point_id):

    object_result = None

    if data_type == "organization":
        object_result = GiseduOrg.objects.get(pk=point_id).the_geom.json
    elif data_type == "school":
        object_result = GiseduSchool.objects.get(pk=point_id).the_geom.json
    elif data_type == "joint_voc_sd":
        object_result = GiseduJointVocationalSchoolDistrict.objects.get(pk=point_id).the_geom.json

    return render_to_response('json/base.json', {'json': object_result}, context_instance=RequestContext(request))


def point_info_by_type(request, data_type, point_id):

    response = None

    if data_type == "organization":
        org = GiseduOrg.objects.get(pk=point_id)
        response = json.dumps({'gid' : int(org.gid), 'name' : org.org_nm, 'type' : org.org_type.org_type_name })

    return render_to_response('json/base.json', {'json': response}, context_instance=RequestContext(request))


def point_infobox_by_type(request, data_type, point_id):

    response = None

    if data_type == "organization":
        org = GiseduOrg.objects.get(pk=point_id)
        response = {'org_name' : org.org_nm, 'address': org.address}
    elif data_type == "school":
        school = GiseduSchool.objects.get(pk=point_id)
        response = {'org_name' : school.school_name, 'address': school.address}
    elif data_type == "joint_voc_sd":
        jvsd = GiseduJointVocationalSchoolDistrict.objects.get(pk=point_id)
        response = {'org_name' : jvsd.jvsd_name, 'address' : jvsd.address}

    return render_to_response('edu_org_info.html', response, context_instance=RequestContext(request))
