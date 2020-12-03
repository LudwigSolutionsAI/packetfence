import { BaseViewCollectionItem } from '../../_components/new/'
import {
  BaseFormButtonBar,
  BaseFormGroupChosenMultiple,
  BaseFormGroupChosenOne,
  BaseFormGroupInput,
  BaseFormGroupInputNumber,
  BaseFormGroupInputPassword,
  BaseFormGroupTextareaUpload,
  BaseFormGroupToggleDisabledEnabled
} from '@/components/new/'
import {
  BaseFormGroupOses,
  BaseFormGroupToggleZeroOneStringAsOffOn
} from '@/views/Configuration/_components/new/'
import TheForm from './TheForm'
import TheView from './TheView'

export {
  BaseViewCollectionItem                  as BaseView,
  BaseFormButtonBar                       as FormButtonBar,

  BaseFormGroupInput                      as FormGroupAccessToken,
  BaseFormGroupInput                      as FormGroupAgentDownloadUri,
  BaseFormGroupInput                      as FormGroupAltAgentDownloadUri,
  BaseFormGroupInput                      as FormGroupAndroidAgentDownloadUri,
  BaseFormGroupInput                      as FormGroupAndroidDownloadUri,
  BaseFormGroupInputPassword              as FormGroupApiPassword,
  BaseFormGroupInput                      as FormGroupApiUrl,
  BaseFormGroupInput                      as FormGroupApiUsername,
  BaseFormGroupInput                      as FormGroupApplicationIdentifier,
  BaseFormGroupInputPassword              as FormGroupApplicationSecret,
  BaseFormGroupToggleDisabledEnabled      as FormGroupApplyRole,
  BaseFormGroupToggleDisabledEnabled      as FormGroupAutoRegister,
  BaseFormGroupInput                      as FormGroupBoardingHost,
  BaseFormGroupInputNumber                as FormGroupBoardingPort,
  BaseFormGroupToggleZeroOneStringAsOffOn as FormGroupBroadcast,
  BaseFormGroupToggleZeroOneStringAsOffOn as FormGroupCanSignProfile,
  BaseFormGroupChosenMultiple             as FormGroupCategory,
  BaseFormGroupTextareaUpload             as FormGroupCertChain,
  BaseFormGroupTextareaUpload             as FormGroupCertificate,
  BaseFormGroupInput                      as FormGroupClientIdentifier,
  BaseFormGroupInputPassword              as FormGroupClientSecret,
  BaseFormGroupInputNumber                as FormGroupCriticalIssuesThreshold,
  BaseFormGroupInput                      as FormGroupDescription,
  BaseFormGroupToggleDisabledEnabled      as FormGroupDeviceTypeDetection,
  BaseFormGroupInput                      as FormGroupDomains,
  BaseFormGroupToggleZeroOneStringAsOffOn as FormGroupDpsk,
  BaseFormGroupChosenOne                  as FormGroupEapType,
  BaseFormGroupToggleDisabledEnabled      as FormGroupEnforce,
  BaseFormGroupInput                      as FormGroupHost,
  BaseFormGroupInput                      as FormGroupIdentifier,
  BaseFormGroupInput                      as FormGroupIosAgentDownloadUri,
  BaseFormGroupInput                      as FormGroupIosDownloadUri,
  BaseFormGroupInput                      as FormGroupLoginUrl,
  BaseFormGroupInput                      as FormGroupMacOsxAgentDownloadUri,
  BaseFormGroupChosenOne                  as FormGroupNonComplianceSecurityEvent,
  BaseFormGroupOses                       as FormGroupOses,
  BaseFormGroupInputPassword              as FormGroupPasscode,
  BaseFormGroupInputPassword              as FormGroupPassword,
  BaseFormGroupChosenOne                  as FormGroupPkiProvider,
  BaseFormGroupInputNumber                as FormGroupPort,
  BaseFormGroupTextareaUpload             as FormGroupPrivateKey,
  BaseFormGroupChosenOne                  as FormGroupProtocol,
  BaseFormGroupInputNumber                as FormGroupPskSize,
  BaseFormGroupToggleDisabledEnabled      as FormGroupQueryComputers,
  BaseFormGroupToggleDisabledEnabled      as FormGroupQueryMobileDevices,
  BaseFormGroupInput                      as FormGroupRefreshToken,
  BaseFormGroupChosenOne                  as FormGroupRoleToApply,
  BaseFormGroupChosenOne                  as FormGroupSecurityType,
  BaseFormGroupInput                      as FormGroupServerCertificatePath,
  BaseFormGroupInput                      as FormGroupSsid,
  BaseFormGroupToggleDisabledEnabled      as FormGroupSyncPid,
  BaseFormGroupInput                      as FormGroupTableForAgent,
  BaseFormGroupInput                      as FormGroupTableForMac,
  BaseFormGroupInput                      as FormGroupTenantCode,
  BaseFormGroupInput                      as FormGroupTenantIdentifier,
  BaseFormGroupInput                      as FormGroupUsername,
  BaseFormGroupInput                      as FormGroupWindowsAgentDownloadUri,
  BaseFormGroupInput                      as FormGroupWindowsPhoneDownloadUri,

  TheForm,
  TheView
}
