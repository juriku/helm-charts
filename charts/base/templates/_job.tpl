{{- define "base.job" -}}
{{- $root := . -}}
---
apiVersion: {{ $root.Values.apiVersion | default "batch/v1" }}
kind: Job
metadata:
  name: {{ include "base.fullname" $root }}
  {{- if $root.Values.namespace }}
  namespace: {{ $root.Values.namespace }}
  {{- end }}
  labels:
    {{- include "base.commonLabels" $root | trim | nindent 4 }}
  {{- if $root.Values.annotations }}
  annotations:
    {{- include "base.valuesPairs" $root.Values.annotations | trim | nindent 4 }}
  {{- end }}
spec:
  {{- if $root.Values.ttlSecondsAfterFinished }}
  ttlSecondsAfterFinished: {{ $root.Values.ttlSecondsAfterFinished }}
  {{- end }}
  {{- if $root.Values.activeDeadlineSeconds }}
  activeDeadlineSeconds: {{ $root.Values.activeDeadlineSeconds }}
  {{- end }}
  {{- if $root.Values.completions }}
  completions: {{ $root.Values.completions }}
  {{- end }}
  {{- if $root.Values.parallelism }}
  parallelism: {{ $root.Values.parallelism }}
  {{- end }}
  backoffLimit: {{ $root.Values.backoffLimit | toString }}
  {{- with $root.Values.podFailurePolicy }}
  podFailurePolicy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  template:
    {{- if or $root.Values.podAnnotations $root.Values.podLabels }}
    metadata:
      {{- if $root.Values.podAnnotations }}
      annotations:
        {{- include "base.valuesPairs" $root.Values.podAnnotations | trim | nindent 8 }}
      {{- end }}
      {{- with $root.Values.podLabels }}
      labels:
        {{- toYaml . | nindent 8 }}
      {{- end }}
    {{- end }}
    spec:
      {{- if $root.Values.podActiveDeadlineSeconds }}
      activeDeadlineSeconds: {{ $root.Values.podActiveDeadlineSeconds }}
      {{- end }}
      {{- with include "base.podDefaultProperties" $root }}
      {{- . | trim | nindent 6 }}
      {{- end }}
      {{- if $root.Values.initContainers }}
      initContainers:
        {{- range $containerName, $containerValues := $root.Values.initContainers }}
        - name: {{ $containerName }}
          {{- include "base.image" (merge dict $containerValues.image $root.Values.image) | nindent 10 }}
          {{- with include "base.containerDefaultProperties" $containerValues }}
          {{- . | trim | nindent 10 }}
          {{- end }}
        {{- end }}
      {{- end }}
      containers:
        {{- range $containerName, $containerValues := $root.Values.extraContainers }}
        - name: {{ $containerName }}
          {{- include "base.image" (merge dict $containerValues.image $root.Values.image) | nindent 10 }}
          {{- with include "base.containerDefaultProperties" $containerValues }}
          {{- . | trim | nindent 10 }}
          {{- end }}
        {{- end }}
        - name: {{ include "base.name" $root }}
          {{- include "base.image" $root.Values.image | nindent 10 }}
          {{- with include "base.containerDefaultProperties" $root.Values }}
          {{- . | trim | nindent 10 }}
          {{- end }}
      {{- with include "base.volumes" $root }}
      {{- . | trim | nindent 6 }}
      {{- end }}
{{- end }}