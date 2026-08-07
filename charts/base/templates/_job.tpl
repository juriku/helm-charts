{{- define "base.job" -}}
{{- $root := . -}}
---
apiVersion: batch/v1
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
    metadata:
      {{- if $root.Values.podAnnotations }}
      annotations:
        {{- include "base.valuesPairs" $root.Values.podAnnotations | trim | nindent 8 }}
      {{- end }}
      labels:
        {{- include "base.labels" $root | trim | nindent 8 }}
        {{- with $root.Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- if $root.Values.podActiveDeadlineSeconds }}
      activeDeadlineSeconds: {{ $root.Values.podActiveDeadlineSeconds }}
      {{- end }}
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
{{- end }}