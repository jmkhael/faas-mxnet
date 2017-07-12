FROM mxnet/python

ADD https://github.com/alexellis/faas/releases/download/0.5.5-alpha/fwatchdog /usr/bin
RUN chmod +x /usr/bin/fwatchdog

RUN wget -q http://data.dmlc.ml/models/imagenet/vgg/vgg16-symbol.json
RUN wget -q http://data.dmlc.ml/models/imagenet/vgg/vgg16-0000.params
RUN wget -q http://data.dmlc.ml/models/imagenet/resnet/152-layers/resnet-152-symbol.json
RUN wget -q http://data.dmlc.ml/models/imagenet/resnet/152-layers/resnet-152-0000.params

WORKDIR /root/

COPY index.py           .
COPY requirements.txt   .
RUN pip install -r requirements.txt

COPY function           function

RUN touch ./function/__init__.py

WORKDIR /root/function/
COPY function/requirements.txt	.
RUN pip install -r requirements.txt

WORKDIR /root/

ENV fprocess="python index.py"

HEALTHCHECK --interval=1s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
