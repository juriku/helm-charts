{{- define "base.statefulSet" -}}
{{- if .Values.statefulSet }}
{{- $root := . -}}
---
apiVersion: apps/v1
kind: {{ include "base.kind" . }}
metadata:
  name: {{ include "base.fullname" $root }}
  {{- if $root.Values.namespace }}
  namespace: {{ $root.Values.namespace }}
  {{- end }}
  labels:
    {{- include "base.labels" $root | trim | nindent 4 }}
    {{- with $root.Values.labelsDeployment }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- if $root.Values.annotations }}
  annotations:
    {{- include "base.valuesPairs" $root.Values.annotations | trim | nindent 4 }}
  {{- end }}
spec:
  {{- if and (not $root.Values.autoscaling.enabled) (not $root.Values.keda.enabled) }}
  replicas: {{ $root.Values.replicas }}
  {{- end }}
  revisionHistoryLimit: {{ $root.Values.revisionHistoryLimit | default 10 }}
  selector:
    matchLabels:
      {{- include "base.selectorLabels" $root | trim | nindent 6 }}
  serviceName: {{ $root.Values.serviceName | default (include "base.fullname" $root) }}
  {{- with $root.Values.strategy }}
  updateStrategy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  template:
    metadata:
      labels:
        {{- include "base.labels" $root | trim | nindent 8 }}
        {{- with $root.Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      {{- $checksums := include "base.configChecksums" $root }}
      {{- if or $root.Values.prometheusScrape $root.Values.podAnnotations $checksums }}
      annotations:
        {{- with $checksums }}
        {{- . | trim | nindent 8 }}
        {{- end }}
        {{- if $root.Values.prometheusScrape }}
        prometheus.io/path: {{ $root.Values.prometheusScrapePath | quote }}
        prometheus.io/port: {{ $root.Values.prometheusScrapePort | quote }}
        prometheus.io/scrape: "true"
        {{- end }}
        {{- if $root.Values.podAnnotations }}
        {{- include "base.valuesPairs" $root.Values.podAnnotations | trim | nindent 8 }}
        {{- end }}
      {{- end }}
    spec:
      {{- with include "base.podDefaultProperties" $root }}
      {{- . | trim | nindent 6 }}
      {{- end }}
      {{- with include "base.initContainers" $root }}
      {{- . | trim | nindent 6 }}
      {{- end }}
      {{- include "base.containers" $root | trim | nindent 6 }}
      {{- with include "base.volumes" $root }}
      {{- . | trim | nindent 6 }}
      {{- end }}
  {{- if $root.Values.volumeClaimTemplates }}
  persistentVolumeClaimRetentionPolicy:
    whenDeleted: {{ $root.Values.persistentVolumeClaimRetentionPolicy.whenDeleted | default "Retain" }}
    whenScaled: {{ $root.Values.persistentVolumeClaimRetentionPolicy.whenScaled | default "Retain" }}
  {{- with $root.Values.volumeClaimTemplates }}
  volumeClaimTemplates:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}