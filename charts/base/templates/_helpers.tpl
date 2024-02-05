{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "base.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "base.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "base.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
labels
*/}}
{{- define "base.labels" -}}
{{- $commonValues := include "base.commonLabels" . | trim | fromYaml -}}
{{- $selectorLabels := include "base.selectorLabels" . | trim | fromYaml -}}
{{- $allLabels := mustMerge $selectorLabels $commonValues -}}
{{- range $key, $value := $allLabels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "base.commonLabels" -}}
{{- if .Values.labels }}
{{- range $key, $value := .Values.labels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- else }}
helm.sh/chart: {{ include "base.chart" . }}
app.kubernetes.io/name: {{ include "base.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- else if .Values.image }}
{{- if .Values.image.tag }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
{{- end }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "base.selectorLabels" -}}
{{- if .Values.selectorLabels }}
{{- range $key, $value := .Values.selectorLabels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- else }}
app: {{ include "base.fullname" . }}
{{- end }}
{{- end }}

{{/*
service port default
*/}}
{{- define "base.servicePortDefaultNum" -}}
{{- $serviceValues := .Values.service | default dict -}}
{{- if $serviceValues.ports }}
{{- with (index $serviceValues.ports 0) }}
{{- .port }}
{{- end }}
{{- else if .Values.ports }}
{{- with (index .Values.ports 0) }}
{{- .containerPort }}
{{- end }}
{{- else }}
{{- printf "80" }}
{{- end }}
{{- end }}

{{/*
range values pairs
*/}}
{{- define "base.valuesPairs" -}}
{{- range $key, $value := . }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}

{{/*
raw.resource will create a resource template that can be
merged with each item in `.Values.resources`.
*/}}
{{- define "raw.resource" -}}
metadata:
  labels:
    {{- include "base.commonLabels" . | trim | nindent 4 }}
{{- end }}