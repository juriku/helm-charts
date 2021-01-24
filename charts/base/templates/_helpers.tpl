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
Common labels
*/}}
{{- define "base.labels" -}}
{{- include "base.selectorLabels" . }}
app.kubernetes.io/name: {{ include "base.name" . }}
helm.sh/chart: {{ include "base.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "base.selectorLabels" -}}
{{- if .Values.selectorLabels }}
{{- range $key, $value := .Values.selectorLabels -}}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- else -}}
app: {{ include "base.fullname" . }}
{{- end }}
{{- end }}

{{/*
extra container volumes
*/}}
{{- define "base.extraVolumes" -}}
{{- if .Values.extraContainers }}
{{- range $containerName, $containerValues := .Values.extraContainers }}
{{- with $containerValues.volumes }}
{{ toYaml . }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
service port default
*/}}
{{- define "base.servicePortDefault" -}}
{{- if .Values.service.ports }}
{{- if .Values.service.ports.http }}
{{- printf "http" }}
{{- else }}
{{- keys .Values.service.ports | first }}
{{- end }}
{{- else if .Values.containerPorts }}
{{- if .Values.containerPorts.http }}
{{- printf "http" }}
{{- else }}
{{- keys .Values.containerPorts | first }}
{{- end }}
{{- else }}
{{- printf "http" }}
{{- end }}
{{- end }}