{{- define "base.deployment" -}}
{{- $root := . -}}
{{- range $deploymentName, $deploymentValuesOverride := .Values.deployments }}
{{- $deploymentValues := merge dict $deploymentValuesOverride $root -}}
{{- if $deploymentValues.enabled }}
---
apiVersion: {{ $deploymentValues.Values.apiVersion | default "apps/v1" }}
kind: Deployment
metadata:
  name: {{ include "base.fullname" $deploymentValues }}
  labels:
    {{- include "base.labels" $deploymentValues | nindent 4 }}
    {{- with $deploymentValues.Values.labelsDeployment }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $deploymentValues.Values.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
{{- if not $deploymentValues.Values.autoscaling.enabled }}
  replicas: {{ $deploymentValues.Values.replicaCount }}
  {{- with $deploymentValues.Values.strategy }}
  strategy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
  {{- if $deploymentValues.Values.minReadySeconds }}
  minReadySeconds: {{ $deploymentValues.Values.minReadySeconds }}
  {{- end }}
  {{- if $deploymentValues.Values.progressDeadlineSeconds }}
  progressDeadlineSeconds: {{ $deploymentValues.Values.progressDeadlineSeconds }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "base.selectorLabels" $deploymentValues | nindent 6 }}
  template:
    metadata:
      {{- if or $deploymentValues.Values.prometheusScrape $deploymentValues.Values.podAnnotations }}
      annotations:
      {{- if $deploymentValues.Values.prometheusScrape }}
        prometheus.io/path: {{ $deploymentValues.Values.prometheusScrapePath }}
        prometheus.io/port: {{ $deploymentValues.Values.prometheusScrapePort }}
        prometheus.io/scrape: "true"
      {{- end }}
    {{- with $deploymentValues.Values.podAnnotations }}
        {{- toYaml . | nindent 8 }}
    {{- end }}
    {{- end }}
      labels:
        {{- include "base.selectorLabels" $deploymentValues | nindent 8 }}
    spec:
      {{- if $deploymentValues.Values.imagePullSecrets }}
      imagePullSecrets:
        - name: {{ $deploymentValues.Values.imagePullSecrets }}
      {{- end }}
      {{- with $deploymentValues.Values.podSecurityContext }}
      securityContext:
{{ toYaml . | indent 8 }}
      {{- end }}
      containers:
        {{- range $containerName, $containerValues := $deploymentValues.Values.extraContainers }}
        - name: {{ $containerName }}
          {{- with $containerValues.securityContext }}
          securityContext:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- include "base.image" (merge dict $containerValues.image $deploymentValues.Values.image) | nindent 10 }}
          {{- with $containerValues.command }}
          command:
{{ toYaml . | indent 12 }}
          {{- end }}
          {{- with $containerValues.args }}
          args:
{{ toYaml . | indent 12 }}
          {{- end }}
          {{- with include "base.environment" $containerValues }}
          {{- . | trim | nindent 10 }}
          {{- end }}
          {{- range $key, $value := $containerValues.containerPorts }}
          ports:
            - name: {{ $key | quote }}
              containerPort: {{ $value }}
              protocol: TCP
          {{- end }}
          {{- with $containerValues.livenessProbe }}
          livenessProbe:
{{ toYaml . | indent 12 }}
          {{- end }}
          {{- with $containerValues.readinessProbe }}
          readinessProbe:
{{ toYaml . | indent 12 }}
          {{- end }}
          {{- with $containerValues.lifecycle}}
          lifecycle:
{{ toYaml . | indent 12 }}
          {{- end }}
          {{- with $containerValues.resources }}
          resources:
{{ toYaml . | indent 12 }}
          {{- end }}
          {{- with $containerValues.volumeMounts }}
          volumeMounts:
{{ toYaml . | indent 12 }}
          {{- end }}
        {{- end }}
        - name: {{ include "base.name" $deploymentValues }}
          {{- with $deploymentValues.Values.securityContext }}
          securityContext:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- include "base.image" $deploymentValues.Values.image | nindent 10 }}
          {{- with $deploymentValues.Values.command }}
          command:
{{ toYaml . | indent 12 }}
          {{- end }}
          {{- with $deploymentValues.Values.args }}
          args:
{{ toYaml . | indent 12 }}
          {{- end }}
          {{- with include "base.environment" $deploymentValues.Values }}
          {{- . | trim | nindent 10 }}
          {{- end }}
          {{- if $deploymentValues.Values.containerPorts }}
          ports:
          {{- range $key, $value := $deploymentValues.Values.containerPorts }}
            - name: {{ $key | quote }}
              containerPort: {{ $value }}
              protocol: TCP
          {{- end }}
          {{- else if $deploymentValues.Values.service.ports }}
          ports:
          {{- range $key, $value := $deploymentValues.Values.service.ports }}
            - name: {{ $key | quote }}
              containerPort: {{ $value }}
              protocol: TCP
          {{- end }}
          {{- end }}
          {{- with $deploymentValues.Values.livenessProbe }}
          livenessProbe:
{{ toYaml . | indent 12 }}
          {{- end }}
          {{- with $deploymentValues.Values.readinessProbe }}
          readinessProbe:
{{ toYaml . | indent 12 }}
          {{- end }}
          {{- with $deploymentValues.Values.lifecycle}}
          lifecycle:
{{ toYaml . | indent 12 }}
          {{- end }}
          {{- with $deploymentValues.Values.resources }}
          resources:
{{ toYaml . | indent 12 }}
          {{- end }}
          {{- with $deploymentValues.Values.volumeMounts }}
          volumeMounts:
{{ toYaml . | indent 12 }}
          {{- end }}
      {{- if $deploymentValues.Values.nodeSelector }}
      nodeSelector:
        {{- toYaml $deploymentValues.Values.nodeSelector | nindent 8 }}
      {{- else if $deploymentValues.Values.nodeSelectorDefault }}
      nodeSelector:
        {{- toYaml $deploymentValues.Values.nodeSelectorDefault | nindent 8 }}
      {{- end }}
      {{- with include "base.affinity" $deploymentValues }}
      {{- . | trim | nindent 6 }}
      {{- end }}
      {{- with $deploymentValues.Values.tolerations }}
      tolerations:
{{ toYaml . | nindent 8 }}
      {{- end }}
      {{- if $deploymentValues.Values.terminationGracePeriodSeconds }}
      terminationGracePeriodSeconds: {{ $deploymentValues.Values.terminationGracePeriodSeconds }}
      {{- end }}
      {{- with include "base.volumes" $deploymentValues }}
      {{- . | trim | nindent 6 }}
      {{- end }}
{{- end }}
{{- end }}
{{- end }}