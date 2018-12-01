# -*- coding: utf-8 -*-
from __future__ import unicode_literals
from django.http import JsonResponse
from django.shortcuts import render, HttpResponse
from .models import *
from django.views.decorators.csrf import csrf_exempt
from notifications import *
# Create your views here.

def test(request):

	return JsonResponse({'resp':"Hello there"})


@csrf_exempt
def uploadImage(request):
	print request.META['CONTENT_TYPE']
	if request.method == 'GET':
		return render(request, 'HomeSecurity/file_upload.html')
	if request.method=='POST':
		hub = NotificationHub("Endpoint=sb://mmvmmv.servicebus.windows.net/;SharedAccessKeyName=DefaultFullSharedAccessSignature;SharedAccessKey=BxCU0HjVsVmWMqFbPUbDFaZ7uAy8xedNk48sAcrUcCI=", "mmv", True)
		gcm_payload = {
		    'data':
		        {
		            'message': 'Please Check!'
		        }
		}
		hub.send_gcm_notification(gcm_payload)
		print request.POST, request.FILES
		instance = ImageUpload(image=request.FILES['image_file'])
		instance.status = 0
		instance.save()
		request.session['new_images'] = True
		return render(request, 'HomeSecurity/file_upload.html')



def sendImage(request):
	if 'new_images' in request.session and request.session['new_images']:
		new_images = ImageUpload.objects.filter(status=0)
		for image in new_images:
			image.status=1
			image.save()


def showActivity(request):
	all_images = ImageUpload.objects.all().order_by('-date')

	if request.is_ajax():
		print 'Json response'
		return JsonResponse({'all_images':list(all_images.values('image', 'date'))})

	# hub = NotificationHub("Endpoint=sb://mmvmmv.servicebus.windows.net/;SharedAccessKeyName=DefaultFullSharedAccessSignature;SharedAccessKey=BxCU0HjVsVmWMqFbPUbDFaZ7uAy8xedNk48sAcrUcCI=", "mmv", True)
	# gcm_payload = {
	#     'data':
	#         {
	#             'message': 'Shit peacefuly!!'
	#         }
	# }
	# hub.send_gcm_notification(gcm_payload)
	# print all_images[0]
	return render(request, 'HomeSecurity/all_activity.html', {'all_images':all_images})


