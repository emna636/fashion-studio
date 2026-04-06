package com.fashionstudio.service;

import com.fashionstudio.model.Commande;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;

@Service
public class FacturePdfService {

	public enum FactureType {
		PROFORMA,
		FACTURE
	}

	public byte[] generate(Commande commande, FactureType type) {
		try (PDDocument doc = new PDDocument()) {
			PDPage page = new PDPage(PDRectangle.A4);
			doc.addPage(page);

			try (PDPageContentStream cs = new PDPageContentStream(doc, page)) {
				float margin = 50;
				float y = page.getMediaBox().getHeight() - margin;
				float x = margin;

				cs.setFont(PDType1Font.HELVETICA_BOLD, 18);
				cs.beginText();
				cs.newLineAtOffset(x, y);
				cs.showText(type == FactureType.FACTURE ? "FACTURE" : "FACTURE PROFORMA");
				cs.endText();

				y -= 28;
				cs.setFont(PDType1Font.HELVETICA, 11);
				writeLine(cs, x, y, "Atelier: " + commande.getUser().getAtelier());
				y -= 16;
				writeLine(cs, x, y, "Client: " + commande.getClient().getPrenom() + " " + commande.getClient().getNom());
				y -= 16;
				writeLine(cs, x, y, "Design: " + commande.getDesign().getNom());
				y -= 16;
				writeLine(cs, x, y, "Statut commande: " + commande.getStatut().name());

				y -= 20;
				cs.setFont(PDType1Font.HELVETICA_BOLD, 12);
				writeLine(cs, x, y, "Détails");
				y -= 16;

				cs.setFont(PDType1Font.HELVETICA, 11);
				BigDecimal prixTotal = commande.getPrixTotal();
				BigDecimal montantPaye = commande.getMontantPaye();
				BigDecimal restant = prixTotal.subtract(montantPaye);

				writeLine(cs, x, y, "Prix total: " + fmt(prixTotal) + " DH");
				y -= 16;
				writeLine(cs, x, y, "Montant payé: " + fmt(montantPaye) + " DH");
				y -= 16;
				writeLine(cs, x, y, "Reste à payer: " + fmt(restant.max(BigDecimal.ZERO)) + " DH");
				y -= 16;

				DateTimeFormatter df = DateTimeFormatter.ofPattern("yyyy-MM-dd").withZone(ZoneId.of("UTC"));
				writeLine(cs, x, y, "Date commande: " + commande.getDateCommande());
				y -= 16;
				writeLine(cs, x, y, "Date livraison: " + commande.getDateLivraison());

				y -= 24;
				cs.setFont(PDType1Font.HELVETICA_OBLIQUE, 10);
				writeLine(cs, x, y, "Généré le: " + df.format(commande.getCreatedAt()));

				if (commande.getNotes() != null && !commande.getNotes().isBlank()) {
					y -= 20;
					cs.setFont(PDType1Font.HELVETICA_BOLD, 12);
					writeLine(cs, x, y, "Notes");
					y -= 16;
					cs.setFont(PDType1Font.HELVETICA, 11);
					writeParagraph(cs, x, y, commande.getNotes(), 500, 14);
				}
			}

			try (ByteArrayOutputStream out = new ByteArrayOutputStream()) {
				doc.save(out);
				return out.toByteArray();
			}
		} catch (IOException e) {
			throw new RuntimeException("Erreur génération PDF", e);
		}
	}

	private static void writeLine(PDPageContentStream cs, float x, float y, String text) throws IOException {
		cs.beginText();
		cs.newLineAtOffset(x, y);
		cs.showText(text);
		cs.endText();
	}

	private static void writeParagraph(PDPageContentStream cs, float x, float y, String text, float maxWidth, float lineHeight)
			throws IOException {
		String[] words = text.replace("\r", "").split("\\s+");
		StringBuilder line = new StringBuilder();

		float cursorY = y;
		for (String w : words) {
			String candidate = line.isEmpty() ? w : (line + " " + w);
			float width = PDType1Font.HELVETICA.getStringWidth(candidate) / 1000 * 11;
			if (width > maxWidth) {
				writeLine(cs, x, cursorY, line.toString());
				cursorY -= lineHeight;
				line = new StringBuilder(w);
			} else {
				line = new StringBuilder(candidate);
			}
		}
		if (!line.isEmpty()) {
			writeLine(cs, x, cursorY, line.toString());
		}
	}

	private static String fmt(BigDecimal v) {
		return v == null ? "0" : v.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString();
	}
}
