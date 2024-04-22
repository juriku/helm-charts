{{/*
define container image
*/}}
{{- define "base.image" -}}
image: "{{ .repository }}:{{ .tag | toString }}"
{{- if .pullPolicy }}
imagePullPolicy: {{ .pullPolicy }}
{{- else }}
{{- if regexMatch "[0-9]" ( .tag | toString ) }}
imagePullPolicy: IfNotPresent
{{- else }}
imagePullPolicy: Always
{{- end }}
{{- end }}
{{- end }}

{{/*
extra pod volumes
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
pod volumes
*/}}
{{- define "base.volumes" -}}
{{- $extraVolumes := include "base.extraVolumes" . -}}
{{- if or $extraVolumes .Values.volumes -}}
volumes:
{{- if $extraVolumes -}}
  {{ $extraVolumes | trim | nindent 2 }}
{{- end }}
{{- with .Values.volumes -}}
  {{ toYaml . | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
pod affinity
*/}}
{{- define "base.affinity" -}}
{{- $podAntiAffinity := .Values.podAntiAffinity | default dict -}}
{{- $deploymentValues := . -}}
{{- if or .Values.affinity $podAntiAffinity.enabled }}
affinity:
{{- with .Values.affinity }}
{{ toYaml . | indent 2 }}
{{- end }}
{{- if $podAntiAffinity.enabled }}
  podAntiAffinity:
  {{- if eq $podAntiAffinity.type "hard" }}
    requiredDuringSchedulingIgnoredDuringExecution:
    {{- range $key, $value := $podAntiAffinity.topology }}
    - labelSelector:
        matchExpressions:
        {{- range $key, $value := $deploymentValues | include "base.selectorLabels" | trim | toString | fromYaml }}
        - key: {{ $key }}
          operator: In
          values:
          - {{ $value }}
        {{- end }}
      topologyKey: {{ .topologyKey }}
    {{- end }}
  {{- else }}
    preferredDuringSchedulingIgnoredDuringExecution:
    {{- range $key, $value := $podAntiAffinity.topology }}
    - weight: {{ .weight | default 100 }}
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          {{- range $key, $value := $deploymentValues | include "base.selectorLabels" | trim | toString | fromYaml }}
          - key: {{ $key }}
            operator: In
            values:
            - {{ $value }}
          {{- end }}
        topologyKey: {{ .topologyKey }}
      {{- end }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
deployemnt Node Scheduling
*/}}
{{- define "base.NodeScheduling" -}}
{{- include "base.affinity" . }}
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{/*
define container vars
*/}}
{{- define "base.environment" -}}
{{- if .environment }}
{{- if or .environment.envFromConfigMaps .environment.envFromSecrets }}
envFrom:
{{- range $configMapName := .environment.envFromConfigMaps }}
  - configMapRef:
      name: {{ $configMapName }}
{{- end }}
{{- range $configMapName := .environment.envFromSecrets }}
  - secretRef:
      name: {{ $configMapName }}
{{- end }}
{{- end }}
env:
{{- range $variableName, $value := .environment.metadata }}
  - name: {{ $variableName }}
    valueFrom:
      fieldRef:
        fieldPath: {{ $value }}
{{- end }}
{{- range $variableName, $opts := .environment.secretVariables }}
  - name: {{ $variableName }}
    valueFrom:
      secretKeyRef:
        name: {{ $opts.name }}
        key: {{ $opts.key }}
{{- end }}
{{- range $variableName, $opts := .environment.configmapVariables }}
  - name: {{ $variableName }}
    valueFrom:
      configMapKeyRef:
        name: {{ $opts.name }}
        key: {{ $opts.key }}
{{- end }}
{{- range $key, $value := .environment.variables }}
{{- $valueStr := $value | toString }}
  - name: {{ $key | quote }}
    value: {{ if eq $valueStr "<nil>" }}""{{ else }}{{ $valueStr | quote }}{{ end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
define pod probes
*/}}
{{- define "base.containerProbes" -}}
{{- with .livenessProbe }}
livenessProbe:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .readinessProbe }}
readinessProbe:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .startupProbe }}
startupProbe:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{/*
define pod lifecycle
*/}}
{{- define "base.containerLifecycle" -}}
{{- with .lifecycle }}
lifecycle:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{/*
define pod resources
*/}}
{{- define "base.containerResources" -}}
{{- with .resources }}
resources:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{/*
define container securityContext
*/}}
{{- define "base.containerSecurityContext" -}}
{{- with .securityContext }}
securityContext:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{/*
define pod securityContext
*/}}
{{- define "base.podSecurityContext" -}}
{{- with .podSecurityContext }}
securityContext:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{/*
define container security
*/}}
{{- define "base.imagePullSecrets" -}}
{{- with .imagePullSecrets }}
imagePullSecrets:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{/*
define pod priority and priorityClass
*/}}
{{- define "base.podPriority" -}}
{{- if .priorityClassName }}
priorityClassName: {{ .priorityClassName }}
{{- end }}
{{- if .priority }}
priority: {{ .priority }}
{{- end }}
{{- if .preemptionPolicy }}
preemptionPolicy: {{ .preemptionPolicy }}
{{- end }}
{{- end }}

{{/*
define pod security
*/}}
{{- define "base.containerVolumeMounts" -}}
{{- with .volumeMounts }}
volumeMounts:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{/*
define pod command and args
*/}}
{{- define "base.containerCommand" -}}
{{- with .command }}
command:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .args }}
args:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{/*
define pod command and args
*/}}
{{- define "base.hostAliases" -}}
{{- if .dnsPolicy }}
dnsPolicy: {{ .dnsPolicy }}
{{- end }}
{{- if .hostNetwork }}
hostNetwork: {{ .hostNetwork }}
{{- end }}
{{- with .hostAliases }}
hostAliases:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{/*
define pod service account
*/}}
{{- define "base.serviceAccount" -}}
{{- if hasKey . "automountServiceAccountToken" }}
automountServiceAccountToken: {{ .automountServiceAccountToken }}
{{- end }}
serviceAccountName: {{ .serviceAccountName | default "default" }}
{{- end }}

{{/*
define topologySpreadConstraints
*/}}
{{- define "base.topologySpreadConstraints" -}}
{{- if or (and (index .Values "topologySpreadConstraintsDefault") (index .Values.topologySpreadConstraintsDefault "enabled")) .Values.topologySpreadConstraints }}
topologySpreadConstraints:
{{- with .Values.topologySpreadConstraints }}
{{ toYaml . | indent 2 }}
{{- end }}
{{- if .Values.topologySpreadConstraintsDefault.enabled }}
- labelSelector:
    matchLabels:
      {{- range $key, $value := include "base.selectorLabels" . | trim | toString | fromYaml }}
      {{ $key }}: {{ $value }}
      {{- end }}
  maxSkew: {{ .Values.topologySpreadConstraintsDefault.maxSkew }}
  topologyKey: {{ .Values.topologySpreadConstraintsDefault.topologyKey }}
  whenUnsatisfiable: {{ .Values.topologySpreadConstraintsDefault.whenUnsatisfiable }}
{{- end }}
{{- end }}
{{- end }}

{{/*
define default pod properties
*/}}
{{- define "base.containerDefaultProperties" -}}
{{- include "base.containerCommand" . }}
{{- include "base.containerSecurityContext" . }}
{{- include "base.environment" . }}
{{- include "base.containerProbes" . }}
{{- include "base.containerLifecycle" . }}
{{- include "base.containerResources" . }}
{{- include "base.containerVolumeMounts" . }}
{{- end }}

{{/*
define default container properties
*/}}
{{- define "base.podDefaultProperties" -}}
{{- include "base.imagePullSecrets" .Values }}
{{- include "base.podSecurityContext" .Values }}
{{- include "base.NodeScheduling" . }}
{{- include "base.serviceAccount" .Values }}
{{- include "base.hostAliases" .Values }}
{{- include "base.podPriority" .Values }}
{{- include "base.topologySpreadConstraints" . }}
enableServiceLinks: {{ hasKey .Values "enableServiceLinks" | ternary .Values.enableServiceLinks true }}
{{- if .Values.restartPolicy }}
restartPolicy: {{ .Values.restartPolicy }}
{{- end }}
{{- if .Values.terminationGracePeriodSeconds }}
terminationGracePeriodSeconds: {{ .Values.terminationGracePeriodSeconds }}
{{- end }}
{{- end }}