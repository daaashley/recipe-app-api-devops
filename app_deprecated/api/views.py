from rest_framework import generics

from .models import Post
from .serializers import PostSerializer

# Create your views here.


class PostView(generics.CreateAPIView):
    queryset = Post.objects.all()
    serializer_class = PostSerializer
