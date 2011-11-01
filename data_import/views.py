# Create your views here.
import csv
import json
from django.core.files.uploadedfile import UploadedFile
from django.http import HttpResponse, HttpResponseNotFound
from django.shortcuts import render_to_response
from django.views.decorators.csrf import csrf_exempt

@csrf_exempt
def upload_csv(request):
    if request.method == "POST":
        for key, value in request.FILES.iteritems():
            fileReader = csv.DictReader(value, delimiter=',', quotechar='"')
            columnDict = {k : [] for k in fileReader.fieldnames}

            for row in fileReader:
                [columnDict[col].append(data) for col, data in row.iteritems()]

            return render_to_response('json/base.json', {'json': json.dumps(columnDict)})
    else:
        return HttpResponseNotFound(mimetype = 'application/json')

def import_csv(request):
    if request.method == "POST":
        csv_data = json.loads(request.raw_post_data)
        print(str(csv_data))
    else:
        return HttpResponseNotFound(mimetype = 'application/json')
