{{- define "base.cronjob" -}}
{{- $root := . -}}
{{- range $deploymentName, $deploymentValuesOverride := .Values.deployments }}
{{- $deploymentValues := merge dict $deploymentValuesOverride $root }}
---
apiVersion: {{ $deploymentValues.Values.apiVersion | default "batch/v1beta1" }}
kind: CronJob
metadata:
{{- if eq ( $deploymentName ) "default" }}
  name: {{ include "base.fullname" $deploymentValues }}
{{- else if $deploymentValues.fullnameOverride }}
  name: {{ include "base.fullname" $deploymentValues }}
{{- else }}
  name: {{ $deploymentName }}
{{- end }}
  {{- if $deploymentValues.Values.annotations }}
  annotations:
    {{- include "base.valuesPairs" $deploymentValues.Values.annotations | trim | nindent 4 }}
  {{- end }}
spec:
  {{- if $deploymentValues.Values.concurrencyPolicy }}
  concurrencyPolicy: {{ $deploymentValues.Values.concurrencyPolicy }}
  {{- end }}
  {{- if $deploymentValues.Values.failedJobsHistoryLimit }}
  failedJobsHistoryLimit: {{ $deploymentValues.Values.failedJobsHistoryLimit }}
  {{- end }}
  {{- if $deploymentValues.Values.successfulJobsHistoryLimit }}
  successfulJobsHistoryLimit: {{ $deploymentValues.Values.successfulJobsHistoryLimit }}
  {{- end }}
  {{- if $deploymentValues.Values.startingDeadlineSeconds }}
  startingDeadlineSeconds: {{ $deploymentValues.Values.startingDeadlineSeconds }}
  {{- end }}
  schedule: {{ $deploymentValues.Values.schedule | quote }}
  jobTemplate:
    spec:
      {{- if $deploymentValues.Values.backoffLimit }}
      backoffLimit: {{ $deploymentValues.Values.backoffLimit }}
      {{- end }}
      template:
        spec:
          {{- with include "base.containerDefaultProperties" $deploymentValues }}
          {{- . | trim | nindent 10 }}
          {{- end }}
          {{- if $deploymentValues.Values.activeDeadlineSeconds }}
          activeDeadlineSeconds: {{ $deploymentValues.Values.activeDeadlineSeconds }}
          {{- end }}
          {{- if $deploymentValues.Values.initContainers }}
          initContainers:
            {{- range $containerName, $containerValues := $deploymentValues.Values.initContainers }}
            - name: {{ $containerName }}
              {{- include "base.image" (merge dict $containerValues.image $deploymentValues.Values.image) | nindent 10 }}
              {{- with include "base.podDefaultProperties" $containerValues }}
              {{- . | trim | nindent 14 }}
              {{- end }}
            {{- end }}
          {{- end }}
          containers:
            {{- range $containerName, $containerValues := $deploymentValues.Values.extraContainers }}
            - name: {{ $containerName }}
              {{- include "base.image" (merge dict $containerValues.image $deploymentValues.Values.image) | nindent 14 }}
              {{- with include "base.podDefaultProperties" $containerValues }}
              {{- . | trim | nindent 14 }}
              {{- end }}
            {{- end }}
            - name: {{ include "base.name" $deploymentValues }}
              {{- include "base.image" $deploymentValues.Values.image | nindent 14 }}
              {{- with include "base.podDefaultProperties" $deploymentValues.Values }}
              {{- . | trim | nindent 14 }}
              {{- end }}
          {{- with include "base.volumes" $deploymentValues }}
          {{- . | trim | nindent 10 }}
          {{- end }}
          restartPolicy: {{ $deploymentValues.Values.restartPolicy }}
{{- end }}
{{- end }}
