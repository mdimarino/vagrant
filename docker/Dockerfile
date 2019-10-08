FROM ubuntu:18.04

ENV COMPANY=company

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install python-virtualenv tzdata -y && ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

RUN groupadd ${COMPANY} && useradd -g ${COMPANY} -d /opt/${COMPANY} -m -s /bin/bash ${COMPANY} && mkdir /opt/${COMPANY}/app && chown -R ${COMPANY}:${COMPANY} /opt/${COMPANY}

USER ${COMPANY}

ENV VIRTUAL_ENV=/opt/${COMPANY}/virtualenv
RUN virtualenv --python=/usr/bin/python ${VIRTUAL_ENV}
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

WORKDIR "/opt/${COMPANY}/app"

# Install dependencies:
COPY requirements.txt .
RUN pip install -r requirements.txt

# Run the application:
COPY myproject.py .
COPY wsgi.py .
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "wsgi:app"]

