import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/craveshield_colors.dart';
import '../widgets/craveshield_button.dart';
import '../widgets/craveshield_screen.dart';
import 'register_screen.dart';

class CraveDisclaimerScreen extends StatefulWidget {
  const CraveDisclaimerScreen({super.key});

  static const routeName = 'craveDisclaimer';
  static const routePath = '/crave-disclaimer';

  @override
  State<CraveDisclaimerScreen> createState() => _CraveDisclaimerScreenState();
}

class _CraveDisclaimerScreenState extends State<CraveDisclaimerScreen> {
  final _scrollController = ScrollController();
  bool _accepted = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CraveShieldScreen(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CraveShieldHeader(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF071326),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .18),
                      width: 1.1,
                    ),
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(22),
                      child: const Text(
                        disclaimerText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          height: 1.55,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF07306F),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .28),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .24),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => setState(() => _accepted = !_accepted),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _accepted,
                            activeColor: Colors.white,
                            checkColor: CraveShieldColors.blue,
                            side: const BorderSide(
                              color: Colors.white,
                              width: 1.8,
                            ),
                            onChanged: (value) {
                              setState(() => _accepted = value ?? false);
                            },
                          ),
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 11),
                              child: Text(
                                'I have read and understood this disclaimer and agree to these terms.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  height: 1.35,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    CraveShieldButton(
                      text: 'I Understand and Continue',
                      onPressed: _accepted
                          ? () => Navigator.of(context).pushNamed(
                                CraveRegisterScreen.routePath,
                              )
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const _DisclaimerBackButton(),
        ],
      ),
    );
  }
}

class CraveShieldHeader extends StatelessWidget {
  const CraveShieldHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F2E6D),
            Color(0xFF174EA6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: .20),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1CCBFF).withValues(alpha: .22),
            blurRadius: 28,
            spreadRadius: 1,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: .28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _HeaderLogoMark(),
          const SizedBox(height: 16),
          const Text(
            'CRAVESHIELD',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'DISCLAIMER, TERMS OF USE &\nLIMITATION OF LIABILITY',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .95),
              fontSize: 14.5,
              height: 1.28,
              fontWeight: FontWeight.w800,
              letterSpacing: .35,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Effective Date: April 2026 | Version 1.0',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .85),
              fontSize: 12,
              height: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderLogoMark extends StatelessWidget {
  const _HeaderLogoMark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        'assets/images/craveshield_logo.svg',
        width: 56,
        height: 56,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _DisclaimerBackButton extends StatelessWidget {
  const _DisclaimerBackButton();

  @override
  Widget build(BuildContext context) {
    if (!Navigator.of(context).canPop()) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 16,
      left: 16,
      child: IconButton(
        tooltip: 'Back',
        color: Colors.white,
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}

const String disclaimerText = r'''
IMPORTANT: PLEASE READ THIS DISCLAIMER CAREFULLY BEFORE USING THE CRAVESHIELD APPLICATION.

BY ACCESSING OR USING THE APP, YOU AGREE TO BE BOUND BY THESE TERMS IN THEIR ENTIRETY. IF YOU DO NOT AGREE, DO NOT USE THIS APP.

CraveShield is a motivational, behavioral-support, wellness, and self-help application designed to help users manage habits, urges, cravings, and personal behavior goals. CraveShield is provided for informational, educational, and self-support purposes only.

CraveShield is NOT a medical device, healthcare service, emergency service, crisis intervention service, therapy program, diagnosis tool, detox program, addiction treatment program, or substitute for professional medical, psychological, psychiatric, legal, financial, or clinical advice.

If you are under 18 years old, you may use CraveShield only with the knowledge and consent of a parent or legal guardian where required by law. By using the App, you confirm that you are at least 18 years old or have obtained all required parent or legal guardian consent.

1. NOT MEDICAL OR CLINICAL ADVICE

CraveShield is designed as a general wellness and self-help support tool only. The content, features, suggestions, reminders, streaks, insights, motivational messages, exercises, notifications, educational materials, and AI-generated guidance provided through the CraveShield application do not constitute medical advice, clinical treatment, diagnosis, therapy, counseling, detoxification support, addiction treatment, or any other form of professional healthcare service.

The App DOES NOT diagnose, treat, cure, prevent, monitor, or manage any addiction, substance use disorder, behavioral health condition, mental health condition, disease, disorder, or medical condition.

The App DOES NOT replace the advice, supervision, evaluation, diagnosis, treatment, or care of any licensed physician, psychiatrist, psychologist, therapist, counselor, addiction specialist, emergency responder, or other qualified healthcare professional.

You should always consult a qualified healthcare professional before making decisions related to addiction treatment, detoxification, medication, withdrawal symptoms, cravings, relapse prevention, mental health, physical health, or any medical or clinical condition.

Do not disregard, avoid, or delay seeking professional medical, psychological, psychiatric, addiction-related, emergency, or clinical advice because of anything displayed, suggested, generated, or communicated by CraveShield.

2. ADDICTION, CRISIS & EMERGENCY SITUATIONS

CraveShield is NOT a crisis intervention service, emergency service, suicide prevention service, medical monitoring service, detox service, or real-time clinical support platform.

If you or someone you know is experiencing a medical emergency, severe withdrawal symptoms, chest pain, seizures, hallucinations, confusion, overdose symptoms, suicidal thoughts, self-harm thoughts, risk of harming others, severe emotional distress, domestic violence, abuse, or any immediate danger, contact local emergency services immediately.

The App is not monitored in real time by any healthcare professional and cannot respond to, assess, manage, prevent, or intervene in crisis situations.

CraveShield cannot guarantee that any feature, message, notification, reminder, AI response, or motivational content will be appropriate, timely, accurate, or sufficient for emergency, clinical, or crisis circumstances.

You are solely responsible for seeking immediate professional assistance when needed.

3. AI-GENERATED CONTENT DISCLAIMER

CraveShield may use artificial intelligence technologies to generate personalized suggestions, insights, reflections, motivational content, habit-support prompts, educational explanations, and other app experiences.

AI-generated content may be inaccurate, incomplete, outdated, unsuitable, misleading, or not appropriate for your individual situation, health condition, mental state, environment, or risk level.

AI responses should never be treated as definitive medical, psychological, legal, financial, clinical, addiction-treatment, crisis-management, or professional recommendations.

You are solely responsible for reviewing, interpreting, and deciding whether to use any AI-generated content. You should independently verify important information and consult qualified professionals where appropriate.

CraveShield does not guarantee the accuracy, completeness, safety, usefulness, appropriateness, or reliability of AI-generated content.

4. LIMITATION OF LIABILITY

TO THE FULLEST EXTENT PERMITTED BY APPLICABLE LAW, CRAVESHIELD, ITS OWNERS, FOUNDERS, DEVELOPERS, AFFILIATES, EMPLOYEES, CONTRACTORS, LICENSORS, SERVICE PROVIDERS, PARTNERS, REPRESENTATIVES, AND AGENTS SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, PUNITIVE, EXEMPLARY, EMOTIONAL, FINANCIAL, HEALTH-RELATED, DATA-RELATED, BUSINESS, PERSONAL, OR OTHER DAMAGES ARISING FROM OR RELATED TO YOUR USE OF, INABILITY TO USE, OR RELIANCE ON THE APP OR ANY APP CONTENT.

This limitation includes, without limitation, damages or losses related to cravings, relapse, substance use, compulsive behavior, health decisions, emotional distress, personal choices, failed goals, missed reminders, inaccurate content, AI-generated output, technical issues, service interruptions, data loss, account access, subscription issues, third-party services, or any action taken or not taken based on information from the App.

You acknowledge that use of CraveShield is at your sole risk and that the App is provided on an "AS IS" and "AS AVAILABLE" basis without warranties of any kind, whether express, implied, statutory, or otherwise.

Some jurisdictions do not allow certain limitations of liability. In those jurisdictions, CraveShield's liability shall be limited to the maximum extent permitted by law.

5. NO GUARANTEE OF RESULTS

CraveShield makes no promises, guarantees, representations, or warranties that using the App will stop, reduce, control, eliminate, prevent, or manage cravings, addictive behaviors, substance use, compulsive habits, relapse, emotional distress, or any other behavior or condition.

Individual results vary. Your progress depends on many factors outside the control of CraveShield, including your personal decisions, consistency, health condition, mental state, environment, support system, professional care, risk level, and circumstances.

The App is a supplementary wellness and self-support tool only. It is not a substitute for professional treatment, structured recovery programs, medical care, therapy, counseling, or emergency assistance.

6. DATA COLLECTION & PRIVACY

By using CraveShield, you acknowledge that the App may collect, process, store, and use account data, usage data, behavioral patterns, self-reported inputs, preferences, progress information, device information, app activity, subscription status, and other information needed to operate, personalize, improve, secure, or support the App.

CraveShield may use this information to provide app features, personalize user experience, support reminders and streaks, improve functionality, analyze usage trends, prevent misuse, and maintain app security.

All data handling is governed by CraveShield's Privacy Policy. You should review the Privacy Policy carefully before using the App.

CraveShield does not guarantee that any electronic transmission, storage system, third-party platform, analytics tool, payment provider, app store, cloud service, or internet-based service is completely secure, uninterrupted, or error-free.

7. SUBSCRIPTIONS, PAYMENTS & REFUNDS

If CraveShield offers paid subscription plans, premium features, trials, in-app purchases, or other paid services, all available fees and terms will be disclosed before purchase through the applicable app store, payment provider, or account interface.

Subscriptions may renew automatically unless cancelled through the applicable app store, payment provider, or account settings before the renewal date.

CraveShield does not control all third-party app store billing rules, refund decisions, payment processing timelines, or subscription management systems.

Refund eligibility, cancellations, renewals, taxes, failed payments, and billing disputes may be subject to the terms of the applicable app store, payment processor, or platform provider.

8. USER RESPONSIBILITIES & PROHIBITED CONDUCT

You agree to use CraveShield only for lawful, personal, non-commercial, wellness, and self-support purposes.

You are responsible for your own choices, actions, behavior, health decisions, account security, device access, interpretation of App content, and use of any information provided by the App.

You agree not to misuse, hack, reverse-engineer, decompile, scrape, copy, reproduce, interfere with, disrupt, overload, exploit, resell, or gain unauthorized access to the App, its systems, its content, its code, its accounts, or its services.

You agree not to use the App to harm, harass, threaten, impersonate, deceive, exploit, or violate the rights, privacy, safety, or security of any person or organization.

You agree not to submit unlawful, harmful, abusive, defamatory, obscene, invasive, misleading, infringing, or otherwise inappropriate content through the App.

CraveShield may restrict, suspend, or terminate access if misuse, prohibited conduct, security risk, legal risk, or violation of these terms is suspected.

9. THIRD-PARTY LINKS & SERVICES

CraveShield may include, integrate with, or rely on third-party websites, platforms, app stores, payment processors, analytics tools, notification services, cloud services, AI services, authentication providers, or external resources.

CraveShield is not responsible for third-party content, policies, availability, security, accuracy, practices, fees, data handling, outages, terms, or damages caused by third-party services.

Your use of third-party services may be governed by separate terms, privacy policies, billing rules, and legal agreements between you and those third parties.

10. INTELLECTUAL PROPERTY

All content, features, designs, code, graphics, logos, names, trademarks, service marks, text, software, visual assets, workflows, user interface elements, and materials within CraveShield are owned by CraveShield or its licensors and are protected by intellectual property and other applicable laws.

You are granted a limited, personal, revocable, non-exclusive, non-transferable license to use the App for its intended personal wellness and self-support purposes.

You may not copy, modify, distribute, sell, lease, sublicense, reverse-engineer, reproduce, publish, exploit, or create derivative works from any part of the App unless expressly permitted in writing by CraveShield.

11. MODIFICATIONS TO THIS DISCLAIMER

CraveShield reserves the right to modify, update, replace, or revise this Disclaimer, Terms of Use, Privacy Policy, or related legal terms at any time.

Changes may be made to reflect updates to the App, legal requirements, business practices, service providers, safety considerations, or user experience.

Continued use of the App after changes are posted or made available means you accept the updated terms.

You are responsible for reviewing this Disclaimer periodically.

12. GOVERNING LAW & DISPUTE RESOLUTION

This Disclaimer shall be governed by the applicable laws of the jurisdiction in which CraveShield is registered, unless otherwise required by mandatory consumer protection or local law.

Any dispute, claim, controversy, or disagreement arising from or related to the App, this Disclaimer, your account, subscriptions, content, privacy, or use of CraveShield shall be handled according to applicable law and the dispute resolution procedures required in the relevant jurisdiction.

Nothing in this Disclaimer limits any non-waivable rights you may have under applicable consumer protection laws.

13. CONTACT INFORMATION

For legal, compliance, privacy, or support questions related to this Disclaimer, contact:

CraveShield Legal & Compliance Team
Email: craveshield@gmail.com
Website: craveshield.app

BY USING CRAVESHIELD, YOU CONFIRM THAT YOU HAVE READ, UNDERSTOOD, AND AGREE TO BE BOUND BY THIS DISCLAIMER, THE TERMS OF USE, THE PRIVACY POLICY, AND ALL LIMITATIONS OF LIABILITY.

© 2026 CraveShield. All Rights Reserved.
''';
