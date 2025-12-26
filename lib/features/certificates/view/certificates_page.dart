import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/data/data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';

class CertificatesPage extends StatefulWidget {
  const CertificatesPage({super.key});
  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends State<CertificatesPage> {
  List<Certificate> _certificates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    try {
      final certs = await context.read<ResumeRepository>().getCertificates();
      setState(() {
        _certificates = certs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    if (_isLoading)
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue));

    return SingleChildScrollView(
      padding:
          EdgeInsets.all(isDesktop ? AppTheme.spacingXxl : AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Certificates', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: AppTheme.spacingSm),
          Text('Professional certifications and credentials',
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppTheme.spacingXl),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900
                  ? 3
                  : constraints.maxWidth > 600
                      ? 2
                      : 1;
              // Adaptive aspect ratio: taller cards for single column (mobile)
              final aspectRatio = crossAxisCount == 1 ? 0.75 : 0.85;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppTheme.spacingMd,
                  mainAxisSpacing: AppTheme.spacingMd,
                  childAspectRatio: aspectRatio,
                ),
                itemCount: _certificates.length,
                itemBuilder: (context, index) =>
                    _CertificateCard(certificate: _certificates[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CertificateCard extends StatefulWidget {
  final Certificate certificate;
  const _CertificateCard({required this.certificate});

  @override
  State<_CertificateCard> createState() => _CertificateCardState();
}

class _CertificateCardState extends State<_CertificateCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          if (widget.certificate.badgeUrl != null &&
              widget.certificate.badgeUrl!.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                backgroundColor: Colors.transparent,
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: 800, maxHeight: 800),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusLarge),
                        child: Image.network(
                          widget.certificate.badgeUrl!,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primaryPurple,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.broken_image,
                                  color: AppTheme.textMuted, size: 64),
                            );
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
        child: AnimatedContainer(
          duration: AppTheme.animNormal,
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
                color: _isHovered
                    ? AppTheme.primaryPurple.withValues(alpha: 0.5)
                    : AppTheme.textMuted.withValues(alpha: 0.1)),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.15),
                        blurRadius: 16)
                  ]
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              if (widget.certificate.badgeUrl != null &&
                  widget.certificate.badgeUrl!.isNotEmpty)
                Image.network(
                  widget.certificate.badgeUrl!,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppTheme.bgCard,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryPurple,
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppTheme.bgCard,
                    child: const Center(
                        child: Icon(Icons.broken_image,
                            color: AppTheme.textMuted)),
                  ),
                )
              else
                Container(
                  color: AppTheme.bgSurface,
                  child: Center(
                    child: Icon(Icons.verified_outlined,
                        size: 48,
                        color: AppTheme.primaryPurple.withValues(alpha: 0.2)),
                  ),
                ),

              // Dark Overlay (Gradient for better readability)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.6),
                      Colors.black.withValues(alpha: 0.9),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingXs),
                          decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSmall),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1))),
                          child: const Icon(Icons.verified_rounded,
                              color: AppTheme.primaryPurple, size: 20),
                        ),
                        const Spacer(),
                        if (widget.certificate.credentialUrl != null &&
                            widget.certificate.credentialUrl!.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.open_in_new,
                                size: 18, color: Colors.white),
                            onPressed: () => launchUrl(
                                Uri.parse(widget.certificate.credentialUrl!)),
                            tooltip: 'View credential',
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(widget.certificate.name,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(widget.certificate.issuer,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('Issued: ${widget.certificate.issueDate}',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12)),
                    if (widget.certificate.description != null &&
                        widget.certificate.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          widget.certificate.description!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
