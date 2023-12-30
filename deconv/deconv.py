import numpy as np
import cv2

def deblur_wiener(image_blurred, kernel, snr):
    # Calculate the Fourier Transform of the blurred image and the kernel
    F_blurred = np.fft.fft2(image_blurred)
    F_kernel = np.fft.fft2(kernel, s=image_blurred.shape)

    # Calculate the Wiener filter
    H_conj = np.conj(F_kernel)
    H_abs = np.abs(F_kernel)**2
    wiener_filter = H_conj / (H_abs + (1 / snr))

    # Apply the Wiener filter to the Fourier Transform of the blurred image
    F_deblurred = F_blurred * wiener_filter

    # Inverse Fourier Transform to obtain the deblurred image
    deblurred_image = np.fft.ifft2(F_deblurred).real

    return deblurred_image

# Load the blurred image and the blur kernel (you need to provide these)
blurred_image = cv2.imread('blurred_image.png', cv2.IMREAD_GRAYSCALE)
blur_kernel = cv2.imread('blur_kernel.png', cv2.IMREAD_GRAYSCALE)

# Set the signal-to-noise ratio (SNR)
snr = 0.01  # You may need to adjust this value depending on the specific case

# Deblur the image using Wiener deconvolution
deblurred_image = deblur_wiener(blurred_image, blur_kernel, snr)

# Display the deblurred image
cv2.imshow('Deblurred Image', deblurred_image)
cv2.waitKey(0)
cv2.destroyAllWindows()
